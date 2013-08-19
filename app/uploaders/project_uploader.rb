# encoding: utf-8

class ProjectUploader < ImageUploader

  version :project_thumb
  version :project_thumb_small
  version :project_thumb_facebook

  def store_dir
    "uploads/project/#{mounted_as}/#{model.id}"
  end

  version :project_thumb do
    process resize_to_fill: [220,172]
    process convert: :png
  end

  version :project_thumb_small, from_version: :project_thumb do
    process resize_to_fill: [85,67]
    process convert: :png
  end

  #facebook requires a minimum thumb size
  version :project_thumb_facebook do
    process resize_to_fill: [512,400]
    process convert: :png
  end

end
