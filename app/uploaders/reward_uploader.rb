# encoding: utf-8
# frozen_string_literal: true

class RewardUploader < ImageUploader
    version :thumb_reward
  
    version :thumb_reward do
      process resize_to_fill: [119, 121]
      process convert: :jpg
    end
  
end
  