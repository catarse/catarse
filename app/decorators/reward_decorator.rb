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
    I18n.t('rewards.index.display_remaining', remaining: source.remaining, maximum: source.maximum_contributions)
  end

  def name
    deliver = %{
      <div class="fontsize-smallest fontcolor-secondary">
        Estimativa de entrega:&nbsp;#{source.display_deliver_estimate || I18n.t('projects.contributions.no_estimate')}
      </div>
    }
    %{
      <label data-minimum-value="#{source.minimum_value > 0 ? number_with_precision(source.minimum_value, precison: 2) : '10,00'}" class="w-form-label fontsize-base fontweight-semibold u-marginbottom-10" for="contribution_reward#{source.id && "_#{source.id}"}">#{source.minimum_value > 0 ? "#{source.display_minimum}  #{I18n.t('rewards.index.or_more')}" : I18n.t('rewards.index.dont_want')}</label>
      <div class="w-row back-reward-money w-hidden">
        <div class="w-col w-col-8 w-col-small-8 w-col-tiny-8 w-sub-col-middle w-clearfix">
          <div class="w-row">
            <div class="w-col w-col-3 w-col-small-3 w-col-tiny-3">
              <div class="back-reward-input-reward placeholder">R$</div>
            </div>
            <div class="w-col w-col-9 w-col-small-9 w-col-tiny-9">
              <input class="user-reward-value w-input back-reward-input-reward" type="tel" min="#{number_with_precision(source.minimum_value, precison: 2)}" placeholder="#{source.minimum_value > 0 ? number_with_precision(source.minimum_value, precison: 2) : '10,00'}">
            </div>
          </div>
          <div class="fontsize-smaller text-error u-marginbottom-20 w-hidden"><span class="fa fa-exclamation-triangle"></span> O valor do apoio está incorreto</div>
        </div>
        <div class="submit-form w-col w-col-4 w-col-small-4 w-col-tiny-4"><a class="btn btn-large" href="#">Continuar&nbsp;&nbsp;<span class="fa fa-chevron-right"></span></a>
        </div>
      </div>
      <div class="back-reward-reward-description">
        <div class="fontsize-smaller u-marginbottom-10">#{html_escape(source.description)}</div>
        #{source.id ? deliver : ''}
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
    auto_html(source.description){ html_escape; simple_format }
  end
end
