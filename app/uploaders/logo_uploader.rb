# encoding: utf-8

class LogoUploader < CarrierWave::Uploader::Base
  include CarrierWave::RMagick

  begin
    if Rails.env.production? and Configuration.find_by_name('aws_access_key')
      storage :s3
    else
      storage :file
    end
  rescue Exception => e
    Rails.logger.error "There is no configuratons table: #{e.inspect}"
  end

  def store_dir
    "uploads/#{model.class.to_s.underscore}/#{mounted_as}/#{model.id}"
  end

  version :thumb do
    process :resize_to_fill => [260,170]
    process :convert => :png
  end
end
