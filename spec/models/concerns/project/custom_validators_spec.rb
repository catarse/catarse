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

  describe '#no_base64_images' do
    let(:project) { Project.new }

    context 'when about_html has base64 images' do
      before do
        project.about_html = "<img src='data:image/png;base64'></img>"
        project.valid?
      end

      it 'adds error message to about_html'  do
        expect(project.errors[:about_html]).to include(I18n.t("errors.messages.base64_images_not_allowed"))
      end
    end

    context 'when about_html hasn`t base64 images' do
      before do
        project.about_html = "<img src='image.png'></img>"
        project.valid?
      end

      it 'don`t add error message to about_html' do
        expect(project.errors[:about_html]).to_not include(I18n.t("errors.messages.base64_images_not_allowed"))
      end
    end

    context 'when budget has base64 images' do
      before do
        project.budget = "<img src='data:image/png;base64'></img>"
        project.valid?
      end

      it 'adds error message to budget' do
        expect(project.errors[:budget]).to include(I18n.t("errors.messages.base64_images_not_allowed"))
      end
    end

    context 'when budget hasn`t base64 images' do
      before do
        project.budget = "<img src='image.png'></img>"
        project.valid?
      end

      it 'don`t add error message to budget' do
        expect(project.errors[:budget]).to_not include(I18n.t("errors.messages.base64_images_not_allowed"))
      end
    end
  end

end
