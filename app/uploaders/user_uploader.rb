# encoding: utf-8

class UserUploader < ImageUploader

  version :thumb_avatar

  version :thumb_avatar do
    process resize_to_fill: [119,121]
    process convert: :png
  end

end
