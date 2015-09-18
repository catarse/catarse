# encoding: utf-8

class ProjectUploader < ImageUploader

  version :project_thumb
  version :project_thumb_small
  version :project_thumb_large
  version :project_thumb_facebook
  version :project_thumb_video_cover

  def store_dir
    "uploads/project/#{mounted_as}/#{model.id}"
  end

  version :project_thumb do
    process resize_to_fill: [220,172]
    process convert: :jpg
  end

  version :project_thumb_small, from_version: :project_thumb do
    process resize_to_fill: [85,67]
    process convert: :jpg
  end

  version :project_thumb_large do
    process resize_to_fill: [600,340]
    process convert: :jpg
  end

  version :project_thumb_large do
    process resize_to_fill: [600,340]
    process convert: :jpg
  end

  #facebook requires a minimum thumb size
  version :project_thumb_video_cover do
    process resize_to_fill: [666,488]
    process convert: :jpg
  end

end
