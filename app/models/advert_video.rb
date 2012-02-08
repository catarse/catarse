class AdvertVideo < ActiveRecord::Base
  has_vimeo_video :video_url, :message => I18n.t('project.vimeo_regex_validation')
  validates :title, :description, :video_url, :presence => true
  
  scope :visibles, where("visible is true")
  scope :random, order("random()")
end
