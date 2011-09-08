# encoding: utf-8

class LogoUploader < CarrierWave::Uploader::Base

  if Rails.env.production? and Configuration.find_by_name('aws_access_key')
    storage :s3
  else
    storage :file
  end

  def store_dir
    "uploads/#{model.class.to_s.underscore}/#{mounted_as}/#{model.id}"
  end
end
