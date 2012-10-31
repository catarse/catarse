require 'spec_helper'

describe LogoUploader do
  include CarrierWave::Test::Matchers
  let(:user){ Factory(:user) }

  before do
    LogoUploader.enable_processing = true
    @uploader = LogoUploader.new(user, :uploaded_image)
    @uploader.store!(File.open("#{Rails.root}/spec/fixtures/image.png"))
  end

  after do
    LogoUploader.enable_processing = false
    @uploader.remove!
  end

  describe '#thumb' do
    subject{ @uploader.thumb }
    it{ should have_dimensions(260, 170) }
  end

  describe '#thumb_avatar' do
    subject{ @uploader.thumb_avatar }
    it{ should have_dimensions(255, 300) }
  end

  describe ".choose_storage" do
    subject{ LogoUploader.choose_storage }

    context "when not in production env" do
      it{ should == :file }
    end

    context "when in production env" do
      before do
        Rails.env.stubs(:production?).returns(true)
        Configuration[:aws_access_key] = 'test'
      end
      it{ should == :fog }
    end
  end

  describe "#cache_dir" do
    subject{ @uploader.cache_dir }
    it{ should == "#{Rails.root}/tmp/uploads" }
  end

  describe "#store_dir" do
    subject{ @uploader.store_dir }
    it{ should == "uploads/user/uploaded_image/#{user.id}" }
  end
end
