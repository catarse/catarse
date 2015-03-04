# encoding: utf-8

class UserUploader < ImageUploader

  version :thumb_avatar

  version :thumb_avatar do
    process resize_to_fill: [119,121]
    process convert: :jpg
  end

  #facebook requires a minimum thumb size
  version :thumb_facebook do
    process resize_to_fill: [512,400]
    process convert: :jpg
  end
end
