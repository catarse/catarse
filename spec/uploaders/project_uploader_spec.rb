require 'spec_helper'

describe ProjectUploader do
  include CarrierWave::Test::Matchers
  let(:project){ FactoryGirl.create(:project) }

  before do
    ProjectUploader.enable_processing = true
    @uploader = ProjectUploader.new(project, :uploaded_image)
    @uploader.store!(File.open("#{Rails.root}/spec/fixtures/image.png"))
  end

  after do
    ProjectUploader.enable_processing = false
    @uploader.remove!
  end

  describe '#project_thumb' do
    subject{ @uploader.project_thumb }
    it{ should have_dimensions(220, 172) }
  end

  describe '#project_thumb' do
    subject{ @uploader.project_thumb_small }
    it{ should have_dimensions(85, 67) }
  end

  describe '#project_thumb' do
    subject{ @uploader.project_thumb_facebook }
    it{ should have_dimensions(512, 400) }
  end

  describe "#store_dir" do
    subject{ @uploader.store_dir }
    it{ should == "uploads/project/uploaded_image/#{project.id}" }
  end
end
