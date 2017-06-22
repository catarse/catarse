# encoding: utf-8
# frozen_string_literal: true

class ImageUploader < CarrierWave::Uploader::Base
  include CarrierWave::MiniMagick

  def extension_white_list
    %w[jpg jpeg png] unless mounted_as == :video_thumbnail
  end

  def self.choose_storage
    CatarseSettings.get_without_cache(:aws_access_key).present? ? :fog : :file
  end

  storage choose_storage

  def store_dir
    "uploads/#{model.class.to_s.underscore}/#{mounted_as}/#{model.id}"
  end

  def cache_dir
    "#{Rails.root}/tmp/uploads"
  end

  process quality: 80
end
