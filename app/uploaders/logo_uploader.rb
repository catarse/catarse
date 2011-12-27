# encoding: utf-8

class LogoUploader < CarrierWave::Uploader::Base
  include CarrierWave::RMagick

  def self.s3_config?
    Rails.env.production? and Configuration[:aws_access_key]
  end

  storage s3_config? ? :s3 : :file

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
end
