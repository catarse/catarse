# coding: utf-8
require 'rails_autolink'
class Reward < ActiveRecord::Base
  include ActionView::Helpers::NumberHelper
  include ActionView::Helpers::TextHelper
  include ActionView::Helpers::UrlHelper
  include RankedModel

  include ERB::Util
  schema_associations

  ranks :row_order, with_same: :project_id
  has_paper_trail

  validates_presence_of :minimum_value, :description, :days_to_delivery
  validates_numericality_of :minimum_value, greater_than_or_equal_to: 10.00
  validates_numericality_of :maximum_backers, only_integer: true, greater_than: 0, allow_nil: true
  scope :remaining, -> { where("maximum_backers IS NULL OR (maximum_backers IS NOT NULL AND (SELECT COUNT(*) FROM backers WHERE state = 'confirmed' AND reward_id = rewards.id) < maximum_backers)") }
  scope :sort_asc, -> { order('id ASC') }

  def has_modification?
    versions.count > 1
  end

  def sold_out?
    maximum_backers && total_compromised >= maximum_backers
  end

  def total_compromised
    backers.with_states(['confirmed', 'waiting_confirmation']).count
  end

  def remaining
    return nil unless maximum_backers
    maximum_backers - total_compromised
  end

  def display_deliver_prevision
    I18n.l((project.expires_at + days_to_delivery.days), format: :prevision)
  rescue
    days_to_delivery
  end

  def display_remaining
    I18n.t('reward.display_remaining', remaining: remaining, maximum: maximum_backers).html_safe
  end

  def name
    "<div class='reward_minimum_value'>#{minimum_value > 0 ? display_minimum+'+' : I18n.t('reward.dont_want')}</div><div class='reward_description'>#{h description}</div>#{'<div class="sold_out">' + I18n.t('reward.sold_out') + '</div>' if sold_out?}<div class='clear'></div>".html_safe
  end
  
  def display_minimum
    number_to_currency minimum_value
  end

  def short_description
    truncate description, length: 35
  end

  def medium_description
    truncate description, length: 65
  end

  def last_description
    if versions.present?
      reward = versions.last.reify(has_one: true)
      auto_link(simple_format(reward.description), html: {target: :_blank})
    end
  end

  def display_description
    auto_link(simple_format(description), html: {target: :_blank})
  end
end
