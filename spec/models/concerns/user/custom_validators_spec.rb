# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Project::CustomValidators, type: :model do
  describe '#no_base64_images' do
    let(:user) { User.new }

    context 'when about_html has base64 images' do
      before do
        user.about_html = "<img src='data:image/png;base64'></img>"
        user.valid?
      end

      it 'adds error message to about_html'  do
        expect(user.errors[:about_html]).to include(I18n.t("errors.messages.base64_images_not_allowed"))
      end
    end

    context 'when about_html hasn`t base64 images' do
      before do
        user.about_html = "<img src='image.png'></img>"
        user.valid?
      end

      it 'don`t add error message to about_html' do
        expect(user.errors[:about_html]).to_not include(I18n.t("errors.messages.base64_images_not_allowed"))
      end
    end
  end
end
