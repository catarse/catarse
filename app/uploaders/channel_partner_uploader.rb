# encoding: utf-8

class ChannelPartnerUploader < ImageUploader

  version :project_thumb
  version :project_thumb_small
  version :project_thumb_facebook

  def store_dir
    "uploads/project/#{mounted_as}/#{model.id}"
  end

  version :medium do
    process resize_to_fill: [370,320]
    process convert: :jpg
  end

  version :thumb do
    process resize_to_fill: [220,172]
    process convert: :jpg
  end

  version :thumb_small, from_version: :project_thumb do
    process resize_to_fill: [85,67]
    process convert: :jpg
  end
end
