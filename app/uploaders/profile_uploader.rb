# encoding: utf-8
# frozen_string_literal: true

class ProfileUploader < ImageUploader
  version :curator_thumb do
    process resize_to_limit: [1200, 630]
    process convert: :jpg
  end
end
