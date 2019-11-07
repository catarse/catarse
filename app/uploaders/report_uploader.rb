# encoding: utf-8
# frozen_string_literal: true

class ReportUploader < CarrierWave::Uploader::Base
  #include CarrierWave::MiniMagick

  def extension_white_list
    %w[csv xls]
  end

  def self.is_remote
    CatarseSettings.get_without_cache(:aws_access_key).present?
  end

  def self.choose_storage
    self.is_remote ? :fog : :file
  end

  storage choose_storage

  def store_dir
    "uploads/#{model.class.to_s.underscore}/#{mounted_as}/#{model.id}"
  end

  def cache_dir
    "#{Rails.root}/tmp/uploads"
  end

  def initialize(*)
    super

    self.fog_directory = report_bucket if ReportUploader.choose_storage == :fog
  end

  def report_bucket
    CatarseSettings.get_without_cache(:project_report_buckets)
  end

  def uploaded_file_location
    ReportUploader.is_remote ? url : file.read
  end
end
