require 'spec_helper'

describe UserUploader do
  include CarrierWave::Test::Matchers
  let(:user){ FactoryGirl.create(:user) }

  before do
    UserUploader.enable_processing = true
    @uploader = UserUploader.new(user, :uploaded_image)
    @uploader.store!(File.open("#{Rails.root}/spec/fixtures/image.png"))
  end

  after do
    UserUploader.enable_processing = false
    @uploader.remove!
  end

  describe '#thumb_avatar' do
    subject{ @uploader.thumb_avatar }
    it{ should have_dimensions(119, 121) }
  end

end
