class CuratedPage < ActiveRecord::Base
  has_many :projects

  validates_uniqueness_of :permalink
  validates_presence_of :permalink, :name, :image_url

  def to_param
    permalink
  end

  before_create :save_permalink
  def save_permalink
    permalink = name.parameterize
  end

end
