# coding: utf-8
class Reward < ActiveRecord::Base
  include ActionView::Helpers::NumberHelper
  include ActionView::Helpers::TextHelper

  include ERB::Util
  belongs_to :project
  has_many :backers
  validates_presence_of :minimum_value, :description
  validates_numericality_of :minimum_value, :greater_than_or_equal_to => 1.00
  validates_numericality_of :maximum_backers, :only_integer => true, :greater_than => 0, :allow_nil => true
  scope :sold_out, where("maximum_backers IS NOT NULL AND (SELECT COUNT(*) FROM backers WHERE confirmed AND reward_id = rewards.id) >= maximum_backers")
  scope :remaining, where("maximum_backers IS NULL OR (maximum_backers IS NOT NULL AND (SELECT COUNT(*) FROM backers WHERE confirmed AND reward_id = rewards.id) < maximum_backers)")
  def sold_out?
    maximum_backers and backers.confirmed.count >= maximum_backers
  end
  def remaining
    return nil unless maximum_backers
    maximum_backers - backers.confirmed.count
  end
  def display_remaining
    I18n.t('reward.display_remaining', :remaining => remaining, :maximum => maximum_backers)
  end
  def name
    "<div class='reward_minimum_value'>#{(minimum_value > 0 ? display_minimum+'+' : I18n.t('reward.dont_want'))}</div><div class='reward_description'>#{h(description)}</div>#{'<div class="sold_out">' + I18n.t('reward.sold_out') + '</div>' if sold_out?}<div class='clear'></div>".html_safe
  end
  def display_minimum
    number_to_currency minimum_value, :unit => 'R$', :precision => 2, :delimiter => '.'
  end
  def short_description
    truncate description, :length => 35
  end
  def medium_description
    truncate description, :length => 65
  end
  def as_json(options={})
    {
      :id => id,
      :display_minimum => display_minimum,
      :description => description,
      :short_description => short_description,
      :medium_description => medium_description
    }
  end
end
