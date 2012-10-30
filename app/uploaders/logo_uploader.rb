# encoding: utf-8

class LogoUploader < CarrierWave::Uploader::Base
  include CarrierWave::RMagick

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

  version :thumb do
    process :resize_to_fill => [260,170]
    process :convert => :png
  end

  version :thumb_avatar do
    process :resize_to_fit => [300,300]
    process :convert => :png
  end
end
