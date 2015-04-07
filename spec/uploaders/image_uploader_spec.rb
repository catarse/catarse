require 'rails_helper'

RSpec.describe ImageUploader do
  include CarrierWave::Test::Matchers
  let(:project){ FactoryGirl.create(:project) }

  before do
    ImageUploader.enable_processing = true
    @uploader = ImageUploader.new(project, :uploaded_image)
    @uploader.store!(File.open("#{Rails.root}/spec/fixtures/image.png"))
  end

  after do
    ImageUploader.enable_processing = false
  end

  describe "#extension_white_list" do
    subject{ @uploader.extension_white_list }

    context "when it's mounted as anything but :video_thumbnail" do
      it{ is_expected.to eq(%w(jpg jpeg gif png)) }
    end

    context "when it's mounted as :video_thumbnail" do
      before do
        allow(@uploader).to receive(:mounted_as).and_return(:video_thumbnail)
      end
      it{ is_expected.to be_nil }
    end
  end

  describe ".choose_storage" do
    subject{ ImageUploader.choose_storage }

    context "when not in production env" do
      it{ is_expected.to eq(:file) }
    end

    context "when in production env" do
      before do
        allow(Rails.env).to receive(:production?).and_return(true)
        CatarseSettings[:aws_access_key] = 'test'
      end
      it{ is_expected.to eq(:fog) }
    end
  end

  describe "#cache_dir" do
    subject{ @uploader.cache_dir }
    it{ is_expected.to eq("#{Rails.root}/tmp/uploads") }
  end

  describe "#store_dir" do
    subject{ @uploader.store_dir }
    it{ is_expected.to eq("uploads/project/uploaded_image/#{project.id}") }
  end
end
