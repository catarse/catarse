# coding: utf-8
class ProjectsController < ApplicationController
  include ActionView::Helpers::DateHelper

  load_and_authorize_resource only: [ :update, :destroy ]

  inherit_resources
  has_scope :pg_search, :by_category_id, :recent, :expiring, :successful, :recommended, :not_expired
  respond_to :html, :except => [:backers]
  respond_to :json, :only => [:index, :show, :backers, :update]
  skip_before_filter :detect_locale, :only => [:backers]

  def index
    index! do |format|
      format.html do
        @title = t("site.title")
        collection_projects = Project.recommended_for_home
        unless collection_projects.empty?
          if current_user and current_user.recommended_project
            @recommended_project = current_user.recommended_project
            collection_projects = collection_projects.where("id != ? AND category_id != ?", current_user.recommended_project.id, @recommended_project.category_id)
          end
          @first_project, @second_project, @third_project, @fourth_project = collection_projects.all
        end

        project_ids = collection_projects.map{|p| p.id }
        project_ids << @recommended_project.id if @recommended_project

        @expiring = Project.expiring_for_home(project_ids)
        @recent = Project.recent_for_home(project_ids)
        @blog_posts = blog_posts
        @last_tweets = last_tweets
      end

      format.json do
        @projects = apply_scopes(Project).visible.order_for_search
        respond_with(@projects.includes(:project_total, :user, :category).page(params[:page]).per(6))
      end
    end
  end

  def start
    return unless require_login
    @title = t('projects.start.title')
  end

  def new
    return unless require_login
    new! do
      @title = t('projects.new.title')
      @project.rewards.build
    end
  end

  def create
    params[:project][:expires_at] += (23.hours + 59.minutes + 59.seconds) if params[:project][:expires_at]
    validate_rewards_attributes if params[:project][:rewards_attributes].present?
    create!(:notice => t('projects.create.success'))
    # When it can't create the project the @project doesn't exist and then it causes a record not found
    # because @project.reload *works only with created records*
    unless @project.new_record?
      @project.reload
      @project.update_attributes({ short_url: bitly })
    end
  end

  def show
    begin
      if params[:permalink].present?
        @project = Project.find_by_permalink! params[:permalink]
      else
        return redirect_to project_by_slug_path(resource.permalink)
      end

      show!{
        @title = @project.name
        @rewards = @project.rewards.includes(:project).order(:minimum_value).all
        @backers = @project.backers.confirmed.limit(12).order("confirmed_at DESC").all
        fb_admins_add(@project.user.facebook_id) if @project.user.facebook_id
        @update = @project.updates.where(:id => params[:update_id]).first if params[:update_id].present?
      }
    rescue ActiveRecord::RecordNotFound
      return render_404
    end
  end

  def vimeo
    project = Project.new(:video_url => params[:url])
    if project.vimeo.info
      render :json => project.vimeo.info.to_json
    else
      render :json => {:id => false}.to_json
    end
  end

  def check_slug
    project = Project.where("permalink = ?", params[:permalink])
    render :json => {:available => project.empty?}.to_json
  end

  def embed
    @project = Project.find params[:id]
    @title = @project.name
    render :layout => 'embed'
  end

  def video_embed
    @project = Project.find params[:id]
    @title = @project.name
    render :layout => 'embed'
  end

  private
  def last_tweets
    Rails.cache.fetch('last_tweets', :expires_in => 30.minutes) do
      begin
        JSON.parse(Net::HTTP.get(URI("http://api.twitter.com/1/statuses/user_timeline.json?screen_name=#{::Configuration[:twitter_username]}")))[0..1]
      rescue
        []
      end
    end
  end

  def blog_posts
    Blog.fetch_last_posts.inject([]) do |total,item|
      total << item if total.size < 2
      total
    end
  rescue
    []
  end

  # Just to fix a minor bug,
  # when user submit the project without some rewards.
  def validate_rewards_attributes
    rewards = params[:project][:rewards_attributes]
    rewards.each do |r|
      rewards.delete(r[0]) unless Reward.new(r[1]).valid?
    end
  end

  def bitly
    return unless Rails.env.production?
    require 'net/http'
    res = Net::HTTP.start("api.bit.ly", 80) { |http| http.get("/v3/shorten?login=diogob&apiKey=R_76ee3ab860d76d0d1c1c8e9cc5485ca1&longUrl=#{CGI.escape(project_by_slug_url(permalink: @project.permalink))}") }
    data = JSON.parse(res.body)['data']
    data['url'] if data
  end
end
