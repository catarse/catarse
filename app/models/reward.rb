# coding: utf-8
class Reward < ActiveRecord::Base
  include ActionView::Helpers::NumberHelper
  belongs_to :project
  has_many :backers
  validates_presence_of :minimum_value, :description
  validates_length_of :description, :maximum => 140
  validates_numericality_of :minimum_value, :greater_than_or_equal_to => 1.00
  validates_numericality_of :maximum_backers, :only_integer => true, :greater_than => 0, :allow_nil => true
  scope :sold_out, where("maximum_backers IS NOT NULL AND (SELECT COUNT(*) FROM backers WHERE reward_id = rewards.id) >= maximum_backers")
  scope :remaining, where("maximum_backers IS NULL OR (maximum_backers IS NOT NULL AND (SELECT COUNT(*) FROM backers WHERE reward_id = rewards.id) < maximum_backers)")
  def sold_out?
    maximum_backers and backers.count >= maximum_backers
  end
  def remaining
    return nil unless maximum_backers
    maximum_backers - backers.count
  end
  def name
    "<div class='reward_minimum_value'>#{(minimum_value > 0 ? display_minimum + '+' : 'Não quero recompensa')}</div><div class='reward_description'>#{description}</div>#{ '<div class="sold_out">Esgotada</div>' if sold_out? }<div class='clear'></div>".html_safe
  end
  def display_minimum
    number_to_currency minimum_value, :unit => 'R$ ', :precision => 0, :delimiter => '.'
  end
end
