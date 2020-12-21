module LocaleHandler
  extend ActiveSupport::Concern

  included do
    before_action :set_locale
  end

  def set_locale
    return redirect_to url_for(locale: I18n.default_locale, only_path: true) unless is_locale_available?
    I18n.locale = params[:locale] || I18n.default_locale
  end

  def is_locale_available?
    params[:locale].blank? || I18n.available_locales.include?(params[:locale].to_sym)
  end

  def default_url_options
    { locale: I18n.locale }
  end
end
