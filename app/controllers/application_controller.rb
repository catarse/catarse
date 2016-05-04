# coding: utf-8
class ApplicationController < ActionController::Base
  include Concerns::ExceptionHandler
  include Concerns::SocialHelpersHandler
  include Concerns::AnalyticsHelpersHandler
  include Pundit
  if Rails.env.production?
    require "new_relic/agent/instrumentation/rails3/action_controller"
    include NewRelic::Agent::Instrumentation::ControllerInstrumentation
    include NewRelic::Agent::Instrumentation::Rails3::ActionController
  end

  acts_as_token_authentication_handler_for User, fallback: :none
  layout 'catarse_bootstrap'
  protect_from_forgery

  before_filter :configure_permitted_parameters, if: :devise_controller?

  helper_method :referral, :render_projects,
    :render_feeds, :can_display_pending_refund_alert?

  before_filter :set_locale

  before_action :force_www

  def referral
    {
      ref: session[:referral_link],
      domain: session[:origin_referral]
    }
  end

  def can_display_pending_refund_alert?
    @can_display_alert ||= current_user && current_user.pending_refund_payments.present? &&
                            controller_name.to_sym != :bank_accounts &&
                            controller_name.to_sym != :donations &&
                            action_name.to_sym != :no_account_refund
  end

  def render_projects collection, ref, locals = {}
    render_to_string partial: 'projects/card', collection: collection, locals: {ref: ref}.merge!(locals)
  end

  def render_feeds collection, locals = {}
    render_to_string partial: 'users/feeds/feed', collection: collection, locals: locals
  end

  def referral_it!
    if request.env["HTTP_REFERER"] =~ /catarse\.me/
      # For local referrers we only want to store the first ref parameter
      session[:referral_link] ||= params[:ref]
      session[:origin_referral] ||= request.env["HTTP_REFERER"]
    else
      # For external referrers should always overwrite referral_link
      session[:referral_link] = params[:ref]
      session[:origin_referral] = request.env["HTTP_REFERER"]
    end

  end

  # Used on external services and generic email
  # templates, just need to redirect to last
  # updated or created project dashboard
  def redirect_to_last_edit
    authorize Project.new(user_id: current_user.try(:id)), :create?
    lp = current_user.projects.update_ordered.first
    redirect_to edit_project_path lp
  end

  def redirect_to_user_billing
    authorize current_user || User.new(), :edit?
    redirect_to edit_user_path(current_user, anchor: 'billing')
  end

  def redirect_to_user_contributions
    authorize current_user || User.new(), :edit?
    redirect_to edit_user_path(current_user, anchor: 'contributions')
  end

  private
  def force_www
    if request.subdomain.blank? && Rails.env.production?
      return redirect_to url_for(params.merge(subdomain: 'www'))
    end
  end

  def detect_old_browsers
    return redirect_to page_path("bad_browser") if (!browser.modern? || browser.ie9?) && controller_name != 'pages'
  end

  def set_locale
    return redirect_to url_for(locale: I18n.default_locale, only_path: true) unless is_locale_available?
    I18n.locale = params[:locale] || I18n.default_locale
  end

  def is_locale_available?
    params[:locale].blank? || I18n.available_locales.include?(params[:locale].to_sym)
  end

  def after_sign_in_path_for(resource_or_scope)
    (session.delete(:return_to) || root_path)
  end

  def redirect_user_back_after_login
    if request.env['REQUEST_URI'].present? && !request.xhr?
      session[:return_to] = request.env['REQUEST_URI']
    end
  end

  def configure_permitted_parameters
    devise_parameter_sanitizer.for(:sign_up) do |u|
      u.permit(:name, :email, :password, :newsletter)
    end
  end
end
