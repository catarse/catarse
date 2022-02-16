# coding: utf-8
# frozen_string_literal: true

require 'uri'
require 'json'

class ApplicationController < ActionController::Base
  EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-]+(\.[a-z\d\-]+)*\.[a-z]+\z/i
  include LocaleHandler
  include ExceptionHandler
  include SocialHelpersHandler
  include AnalyticsHelpersHandler
  include PixelHelpersHandler
  include KondutoHandler
  # include OldBrowserChecker
  include Pundit
  before_action :redirect_when_zendesk_session, unless: :devise_controller?

  acts_as_token_authentication_handler_for User, fallback: :none
  layout 'catarse_bootstrap'
  protect_from_forgery

  before_action :configure_permitted_parameters, if: :devise_controller?

  helper_method :referral, :render_projects, :is_projects_home?,
                :render_feeds, :public_settings

  before_action :force_www
  # before_action :detect_old_browsers

  def referral
    #ctrse_origin is created on frontend (analytics.js).
    #Expected to have this fields: domain,ref,campaign,source,medium,content,term to create an Origin object.
    json = URI::Parser.new.unescape(cookies[:ctrse_origin]) if !cookies[:ctrse_origin].blank?
    ctrse_origin = (JSON.parse(json) if !json.nil?) || {}
    ctrse_origin.with_indifferent_access
  end

  def is_projects_home?
    controller_name == 'projects' && action_name == 'index'
  end

  def render_projects(collection, ref, locals = {})
    render_to_string partial: 'projects/card', collection: collection, locals: { ref: ref }.merge!(locals)
  end

  def render_feeds(collection, locals = {})
    render_to_string partial: 'users/feeds/feed', collection: collection, locals: locals
  end

  def referral_it!
    #does nothing because referral cookie now resides on analytics.js. Will be removed!
  end

  def build_cookie_structure(value)
    if value.present?
      {
        value: value,
        expires: 1.week.from_now
      }
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
    authorize current_user || User.new, :edit?
    redirect_to edit_user_path(current_user, anchor: 'settings')
  end

  def redirect_to_user_contributions
    authorize current_user || User.new, :edit?
    redirect_to edit_user_path(current_user, anchor: 'contributions')
  end

  def connect_facebook
    if user_signed_in? && current_user.has_fb_auth?
      FbFriendCollectorWorker.perform_async(current_user.fb_auth.id)
      redirect_to follow_fb_friends_path
    else
      redirect_to root_path
    end
  end

  def public_settings
    {
      base_url: CatarseSettings[:base_url],
      support_forum: CatarseSettings[:support_forum],
      blog_url: CatarseSettings[:blog_url]
    }.to_json
  end

  def get_blog_posts
    render json: (begin
                    Blog.fetch_last_posts
                  rescue
                    []
                  end)[0..2].to_json
  end

  private

  def redirect_when_zendesk_session
    if session[:zendesk_return].present?
      zlink = session[:zendesk_return].dup
      session[:zendesk_return] = nil
      redirect_to zendesk_session_create_path(return_to: zlink)
    end
  end

  def force_www
    if request.subdomain.blank? && Rails.env.production?
      redirect_to request.original_url.gsub(/^https?\:\/\//, 'https://www.')
    end
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
    devise_parameter_sanitizer.permit(:sign_up, keys: %i[name email password newsletter])
  end

  def after_sign_in_path_for(resource)
    session_return_to = session[:return_to]
    session[:return_to] = nil
    stored_location_for(resource) || session_return_to || root_path
  end

  def after_sign_up_path_for(resource)
    session_return_to = session[:return_to]
    session[:return_to] = nil
    store_location_for(resource) || session_return_to || root_path
  end
end
