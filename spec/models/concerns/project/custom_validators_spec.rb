# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Project::CustomValidators, type: :model do
  describe '#permalink_on_routes?' do
    it 'should allow a unique permalink' do
      expect(Project.permalink_on_routes?('permalink_test')).to eq(false)
    end

    it 'should not allow a permalink to be one of catarse\'s routes' do
      expect(Project.permalink_on_routes?('projects')).to eq(true)
    end
  end

  describe 'ensure_at_least_one_reward_validation' do
    let(:project) { create(:project) }

    subject { project.errors['rewards.size'].present? }

    context 'when project has no rewards' do
      before do
        project.rewards.destroy_all
        project.ensure_at_least_one_reward_validation
      end

      it do
        is_expected.to eq true
      end
    end

    context 'when project has rewads' do
      before do
        create(:reward, project: project)
        project.ensure_at_least_one_reward_validation
      end

      it do
        is_expected.to eq false
      end
    end
  end

  describe '#validate_tags' do
    let(:project) { create(:project) }

    subject { project.errors['public_tags'].present? }

    before do
      project.all_public_tags = '1,2,3,4,5'
      project.save
    end

    context 'when does not have reach maximum of tags' do
      it do
        is_expected.to eq false
      end
    end

    context 'when have reach maximum of tags' do
      before do
        project.all_public_tags = '1,2,3,4,5,6'
        project.save
      end

      it do
        is_expected.to eq true
      end
    end
  end

  describe 'solidarity service fee' do
    
    let(:integrations_attributes) { [{ name: 'SOLIDARITY_SERVICE_FEE', data: { name: 'SOLIDARITY FEE NAME' } }] }
    
    context 'when have solidarity integration and valid fee selected' do

      context 'should allow to save project with service fee under 13%' do

        let(:project) { create(:project) }
  
        subject { project.errors[:service_fee].present? }
  
        before do
          project.attributes = {
            name: 'UNDER13%',
            service_fee: 0.04,
            integrations_attributes: integrations_attributes
          }
          project.save!
        end
  
        it do
          is_expected.to eq false
          expect(project.service_fee).to eq 0.04
          expect(project.name).to eq 'UNDER13%'
        end

      end

      context 'should allow to save project with service fee over 13%' do
        
        let(:project) { create(:project) }
  
        subject { project.errors[:service_fee].present? }

        before do
          project.attributes = {
            name: 'ABOVE13%',
            service_fee: 0.20,
            integrations_attributes: integrations_attributes
          }
          project.save!
        end
  
        it do
          is_expected.to eq false
          expect(project.service_fee).to eq 0.20
          expect(project.name).to eq 'ABOVE13%'
        end

      end

    end

    context 'when have solidarity integration and invalid fee selected' do
      context 'should not allow to save project with service fee over 20%' do
        
        let(:project) { create(:project) }
  
        subject { project.errors[:service_fee].present? }

        before do
          project.attributes = {
            service_fee: 0.21,
            integrations_attributes: integrations_attributes
          }
          project.save
        end
  
        it do
          is_expected.to eq true
        end

      end

      context 'should not allow to save project with service fee under 4%' do
        
        let(:project) { create(:project) }
  
        subject { project.errors[:service_fee].present? }

        before do
          project.attributes = {
            service_fee: 0.03,
            integrations_attributes: integrations_attributes
          }
          project.save
        end
  
        it do
          is_expected.to eq true
        end

      end

      context 'should allow to save project with service fee under 13% when is admin' do
        
        let(:project) { create(:project) }
        let(:user) { create(:user) }
  
        subject { project.errors[:service_fee].present? }

        before do
          user.admin = true
          user.save

          project.attributes = { service_fee: 0.03 }
          project.user = user
          project.save
        end
  
        it do
          is_expected.to eq false
        end

      end
    end

  end
end
