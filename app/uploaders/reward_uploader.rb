# encoding: utf-8
# frozen_string_literal: true

class RewardUploader < ImageUploader
    version :thumb_reward
  
    version :thumb_reward do
      process convert: :jpg
    end
  
end
  