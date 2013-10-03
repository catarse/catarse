# encoding: utf-8

class ProfileUploader < ImageUploader

  version :curator_thumb do
    process resize_to_fill: [195,120]
    process convert: :png
  end

end
