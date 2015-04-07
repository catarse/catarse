require 'rails_helper'

RSpec.describe UserUploader do
  include CarrierWave::Test::Matchers
  let(:user){ FactoryGirl.create(:user) }

  before do
    UserUploader.enable_processing = true
    @uploader = UserUploader.new(user, :uploaded_image)
    @uploader.store!(File.open("#{Rails.root}/spec/fixtures/image.png"))
  end

  after do
    UserUploader.enable_processing = false
  end

  describe '#thumb_avatar' do
    subject{ @uploader.thumb_avatar }
    it{ is_expected.to have_dimensions(119, 121) }
  end

  describe '#thumb_facebook' do
    subject{ @uploader.thumb_facebook }
    it{ is_expected.to have_dimensions(512, 400) }
  end

end
