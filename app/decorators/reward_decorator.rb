class RewardDecorator < Draper::Decorator
  decorates :reward
  include Draper::LazyHelpers
  include AutoHtml

  def display_deliver_estimate
    I18n.l(source.deliver_at, format: :estimate)
  rescue
    source.deliver_at
  end

  def display_remaining
    I18n.t('rewards.index.display_remaining', remaining: source.remaining, maximum: source.maximum_contributions).html_safe
  end

  def name
    %{
      <label class="w-form-label headline" for="contribution_reward_#{source.id}">#{source.minimum_value > 0 ? source.display_minimum+'+' : I18n.t('rewards.index.dont_want')}</label>
      <div class="back-reward-reward-description">
        <p class="body-medium">
        #{html_escape(source.description)}
        </p>
        <div class="back-reward-delivery-date caption">
          Estimativa de entrega:&nbsp;#{source.display_deliver_estimate}
        </div>
      </div>
    }.html_safe
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
      auto_html(reward.description) { simple_format; link(target: '_blank') }
    end
  end

  def display_description
    auto_html(source.description){ simple_format; link(target: '_blank') }
  end
end
