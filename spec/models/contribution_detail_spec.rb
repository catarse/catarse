require 'rails_helper'

RSpec.describe ContributionDetail, type: :model do
  describe "associations" do
    it{ should belong_to :user }
    it{ should belong_to :project }
    it{ should belong_to :reward }
    it{ should belong_to :contribution }
    it{ should belong_to :payment }
  end

  describe ".for_online_projects" do
    let(:project) {create(:project, state:'online')}

    let!(:contribution_1) do
      p = create(:confirmed_contribution, value: 20, project: project).payments.first
      p.update_attributes(payment_method: 'BoletoBancario', state: 'pending')
      p.contribution.details.first
    end
    let!(:contribution_2) do
      p = create(:confirmed_contribution, value: 20, project: project).payments.first
      p.update_attributes(payment_method: 'BoletoBancario')
      p.contribution.details.first
    end
    let!(:contribution_3) do
      p = create(:confirmed_contribution, value: 20, project: project).payments.first
      p.update_attributes(payment_method: 'CartaoDeCredito')
      p.contribution.details.first
    end
    let!(:contribution_4) do
      p = create(:confirmed_contribution, value: 20, project: project).payments.first
      p.update_attributes(payment_method: 'CartaoDeCredito', state: 'deleted')
      p.contribution.details.first
    end

    subject { ContributionDetail.for_online_projects }

    it "should return valid contributions" do
      expect(subject.include?(contribution_1)).to eq(true)
      expect(subject.include?(contribution_2)).to eq(true)
      expect(subject.include?(contribution_3)).to eq(true)
      expect(subject.include?(contribution_4)).to eq(false)
    end

  end

  describe ".slips_past_waiting" do
    subject{ ContributionDetail.slips_past_waiting }

    before do
      @contribution = create(:contribution)
      create(:payment, payment_method: 'BoletoBancario', contribution: @contribution, created_at: 6.days.ago, state: 'pending')
      @credit_contribution = create(:pending_contribution)
      @confirmed_contribution = create(:confirmed_contribution)
    end
    it{is_expected.to match_array [@contribution.details.first] }
  end

  describe ".no_confirmed_contributions_on_project" do
    subject{ ContributionDetail.no_confirmed_contributions_on_project }

    before do
      @contribution = create(:pending_contribution)
      # Same user has a confirmed contribution for another project
      create(:confirmed_contribution, user: @contribution.user)
      @confirmed_contribution = create(:confirmed_contribution)
      create(:pending_contribution, user: @confirmed_contribution.user, project: @confirmed_contribution.project)
    end
    it{is_expected.to match_array [@contribution.details.first] }
  end

  describe '.for_successful_projects' do
    let(:project) { create(:project, goal: 200, state: 'online') }

    subject { ContributionDetail.for_successful_projects }

    before do
      create(:confirmed_contribution, value: 100, project: project)
      create(:confirmed_contribution, value: 100, project: project)
      create(:confirmed_contribution, value: 10)
      create(:contribution, value: 100, project: project)

      project.update_attributes(state: 'successful')
    end

    it { is_expected.to have(2).itens }
  end

  describe '.for_failed_projects' do
    let(:project) { create(:project, goal: 200) }

    subject { ContributionDetail.for_failed_projects }

    before do
      create(:confirmed_contribution, project: project)
      create(:confirmed_contribution, project: project)
      create(:pending_refund_contribution, project: project)
      create(:refunded_contribution, project: project)
      create(:confirmed_contribution)
      create(:contribution, project: project)
      project.update_attributes(state: 'failed')
    end

    it { is_expected.to have(4).itens }
  end

  describe ".was_confirmed" do
    subject{ ContributionDetail.was_confirmed }

    before do
      @contribution = create(:confirmed_contribution)
      @refunded_contribution = create(:refunded_contribution)
      create(:pending_contribution)
    end
    it{ is_expected.to match_array [@contribution.details.first, @refunded_contribution.details.first] }
  end

  describe ".pending" do
    subject{ ContributionDetail.pending }

    before do
      @contribution = create(:pending_contribution)
      create(:confirmed_contribution)
    end
    it{ is_expected.to match_array [@contribution.details.first] }
  end

  describe ".with_state" do
    subject{ ContributionDetail.with_state(:paid) }

    before do
      @contribution = create(:confirmed_contribution)
      create(:pending_contribution)
    end

    it{ is_expected.to match_array [@contribution.details.first] }
  end

  describe ".available_to_display" do
    before do
      create(:confirmed_contribution)
      create(:deleted_contribution)
      create(:refused_contribution)
      create(:pending_contribution)
      create(:pending_contribution, created_at: Time.now - 1.week)
    end

    subject{ ContributionDetail.available_to_display }

    its(:count){ is_expected.to eq 2 }
  end

  describe "#full_text_index" do
    let!(:contribution){ create(:confirmed_contribution, value: 10) }
    let(:detail){ ContributionDetail.first }
    subject{ detail.full_text_index }

    it{ is_expected.to_not be_nil }
  end

  describe "#project_img" do
    let!(:contribution){ create(:confirmed_contribution, value: 10) }
    subject{ ContributionDetail.first.project_img }

    before do
      CatarseSettings[:aws_host] = 's3.aws.com'
      CatarseSettings[:aws_bucket] = 'bucket'
    end

    it{ is_expected.to eq "https://#{CatarseSettings[:aws_host]}/#{CatarseSettings[:aws_bucket]}/uploads/project/uploaded_image/#{contribution.project.id}/project_thumb_small_testimg.png" }
  end

  describe "#user_profile_img" do
    let!(:contribution){ create(:confirmed_contribution, value: 10) }
    subject{ ContributionDetail.first.user_profile_img }

    before do
      CatarseSettings[:aws_host] = 's3.aws.com'
      CatarseSettings[:aws_bucket] = 'bucket'
    end

    it{ is_expected.to eq "https://#{CatarseSettings[:aws_host]}/#{CatarseSettings[:aws_bucket]}/uploads/user/uploaded_image/#{contribution.user.id}/thumb_avatar_testimg.png" }
  end
end
