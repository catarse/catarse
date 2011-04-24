# coding: utf-8
class Site < ActiveRecord::Base
  validates_presence_of :name, :title, :path, :host
  validates_uniqueness_of :name, :path, :host
  has_many :projects
  has_many :projects_sites
  has_many :present_projects, :through => :projects_sites, :source => :project
  has_many :backers
  has_many :users
  def the(capitalize = false)
    if gender == "male"
      text = I18n.t('site.male.the')
    elsif gender == "female"
      text = I18n.t('site.female.the')
    end
    text.capitalize! if capitalize
    text
  end
  def the_name(capitalize = false)
    "#{the(capitalize)} #{name}".strip
  end
  def in_the
    if gender == "male"
      text = I18n.t('site.male.in_the')
    elsif gender == "female"
      text = I18n.t('site.female.in_the')
    end
    text
  end
  def in_the_name
    "#{in_the} #{name}".strip
  end
  def in_the_twitter
    "#{in_the} @#{twitter}".strip
  end
  def to_the
    if gender == "male"
      text = I18n.t('site.male.to_the')
    elsif gender == "female"
      text = I18n.t('site.female.to_the')
    end
  end
  def to_the_name
    "#{to_the} #{name}".strip
  end
end
