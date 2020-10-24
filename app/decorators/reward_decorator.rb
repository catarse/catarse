# frozen_string_literal: true

class RewardDecorator < Draper::Decorator
  decorates :reward
  include Draper::LazyHelpers
  LAST_DESCRIPTION_FORMAT = AutoHtml::Pipeline.new(AutoHtml::SimpleFormat.new, AutoHtml::Link.new(target: '_blank'))
  DISPLAY_DESCRIPTION_FORMAT = AutoHtml::Pipeline.new(AutoHtml::HtmlEscape.new, AutoHtml::SimpleFormat.new)

  def display_deliver_estimate
    I18n.l(object.deliver_at, format: :estimate)
  rescue
    object.deliver_at
  end

  def display_remaining
    I18n.t('rewards.index.display_remaining', remaining: object.remaining, maximum: object.maximum_contributions)
  end

  def name
    deliver = %(
      <div class="fontsize-smallest fontcolor-secondary">
        Estimativa de entrega:&nbsp;#{object.display_deliver_estimate || I18n.t('projects.contributions.no_estimate')}
      </div>
    )
    %(
      <label data-minimum-value="#{object.minimum_value > 0 ? object.minimum_value.to_i : '10'}" class="w-form-label fontsize-base fontweight-semibold u-marginbottom-10" for="contribution_reward#{object.id && "_#{object.id}"}">#{object.minimum_value > 0 ? "#{object.display_minimum}  #{I18n.t('rewards.index.or_more')}" : I18n.t('rewards.index.dont_want')}</label>
      <div class="w-row back-reward-money w-hidden">
        <div class="w-col w-col-8 w-col-small-8 w-col-tiny-8 w-sub-col-middle w-clearfix">
          <div class="w-row">
            <div class="w-col w-col-3 w-col-small-3 w-col-tiny-3">
              <div class="back-reward-input-reward placeholder">R$</div>
            </div>
            <div class="w-col w-col-9 w-col-small-9 w-col-tiny-9">
              <input class="user-reward-value back-reward-input-reward" type="tel" min="#{object.minimum_value.to_i}" placeholder="#{object.minimum_value > 0 ? object.minimum_value.to_i : '10'}">
            </div>
          </div>
          <div class="fontsize-smaller text-error u-marginbottom-20 w-hidden"><span class="fa fa-exclamation-triangle"></span> O valor do apoio está incorreto</div>
        </div>
        <div class="submit-form w-col w-col-4 w-col-small-4 w-col-tiny-4"><a class="btn btn-large" href="#">Continuar&nbsp;&nbsp;<span class="fa fa-chevron-right"></span></a>
        </div>
      </div>
      <div class="back-reward-reward-description">
        <div class="fontsize-smaller u-marginbottom-10">#{html_escape(object.description)}</div>
        #{object.id ? deliver : ''}
      </div>
    ).html_safe
  end

  def display_minimum
    number_to_currency object.minimum_value
  end

  def short_description
    truncate object.description, length: 35
  end

  def medium_description
    truncate object.description, length: 65
  end

  def last_description
    if object.versions.present?
      reward = object.versions.last.reify(has_one: true)
      LAST_DESCRIPTION_FORMAT.call(reward.description)
    end
  end

  def display_description
    DISPLAY_DESCRIPTION_FORMAT.call(object.description)
  end

  def display_label
    "#{object.minimum_value} - #{object.title}"
  end
end
