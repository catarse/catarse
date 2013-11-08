class RewardDecorator < Draper::Decorator
  decorates :reward
  include Draper::LazyHelpers

  def display_deliver_prevision
    I18n.l((source.project.expires_at + source.days_to_delivery.days), format: :prevision)
  rescue
    source.days_to_delivery
  end

  def display_remaining
    I18n.t('reward.display_remaining', remaining: source.remaining, maximum: source.maximum_backers).html_safe
  end

  def name
    "<div class='reward_minimum_value'>#{source.minimum_value > 0 ? source.display_minimum+'+' : I18n.t('reward.dont_want')}</div><div class='reward_description'>#{html_escape(source.description)}</div>#{'<div class="sold_out">' + I18n.t('reward.sold_out') + '</div>' if source.sold_out?}<div class='clear'></div>".html_safe
  end

  def display_minimum
    number_to_currency source.minimum_value
  end

  def short_description
    truncate source.description, length: 35
  end

  def medium_description
    truncate source.description, length: 65
  end

  def last_description
    if source.versions.present?
      reward = source.versions.last.reify(has_one: true)
      auto_link(simple_format(reward.description), html: {target: :_blank})
    end
  end

  def display_description
    auto_link(simple_format(source.description), html: {target: :_blank})
  end
end
