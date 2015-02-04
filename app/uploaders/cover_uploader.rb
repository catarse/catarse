# encoding: utf-8

class CoverUploader < ImageUploader

  version :base

  version :base do
    process resize_to_fill: [1200,800]
    process convert: :jpg
  end

end

