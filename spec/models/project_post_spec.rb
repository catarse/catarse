# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ProjectPost, type: :model do
  describe 'validations' do
    it { is_expected.to validate_presence_of :project_id }
    it { is_expected.to validate_presence_of :user_id }
    it { is_expected.to validate_presence_of :comment_html }
    it { is_expected.to validate_presence_of :title }
  end

  describe 'associations' do
    it { is_expected.to belong_to :user }
    it { is_expected.to belong_to :project }
  end

  describe '.create' do
    subject { create(:project_post, comment_html: 'this is a comment') }
    it { expect(subject.comment_html).to eq 'this is a comment' }
  end

  describe '#no_base64_images' do
    let(:project_post) { create(:project_post) }

    context 'when comment_html has base64 images' do
      before do
        project_post.update comment_html: "<img src='data:image/png;base64'></img>"
        project_post.valid?
      end

      it 'adds error message to comment_html' do
        expect(project_post.errors[:comment_html]).to include(I18n.t("errors.messages.base64_images_not_allowed"))
      end
    end

    context 'when comment_html hasn`t base64 images' do
      before do
        project_post.update comment_html: "<img src='image.png'></img>"
        project_post.valid?
      end

      it 'don`t add error message to comment_html' do
        expect(project_post.errors[:comment_html]).to_not include(I18n.t("errors.messages.base64_images_not_allowed"))
      end
    end
  end
end
