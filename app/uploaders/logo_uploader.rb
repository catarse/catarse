# encoding: utf-8

class LogoUploader < CarrierWave::Uploader::Base
  include CarrierWave::RMagick

  version :project_thumb, :if => :is_project?
  version :thumb, :if => :is_user?
  version :thumb_avatar, :if => :is_user?

  def extension_white_list
    %w(jpg jpeg gif png) unless mounted_as == :video_thumbnail
  end

  def self.choose_storage
    (Rails.env.production? and Configuration[:aws_access_key]) ? :fog : :file
  end

  storage choose_storage

  def store_dir
    "uploads/#{model.class.to_s.underscore}/#{mounted_as}/#{model.id}"
  end

  def cache_dir
    "#{Rails.root}/tmp/uploads"
  end

  version :project_thumb do
    process :resize_to_fill => [512,400]
    process :convert => :png
  end

  version :thumb do
    process :resize_to_fill => [260,170]
    process :convert => :png
  end

  version :thumb_avatar do
    process :resize_to_fit => [300,300]
    process :convert => :png
  end

  protected

  def is_project? picture
    model.class.name == 'Project'
  end

  def is_user? picture
    model.class.name == 'User'
  end

end
