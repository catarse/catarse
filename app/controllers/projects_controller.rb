# coding: utf-8
class ProjectsController < ApplicationController
  include ActionView::Helpers::DateHelper

  inherit_resources
  actions :index, :show, :new, :create
  respond_to :html, :except => [:backers]
  respond_to :json, :only => [:index, :show, :backers]
  can_edit_on_the_spot
  skip_before_filter :detect_locale, :only => [:backers]
  before_filter :can_update_on_the_spot?, :only => :update_attribute_on_the_spot
  before_filter :date_format_convert, :only => [:create]

  def date_format_convert
    # TODO localize here and on the datepicker on project_form.js
    params["project"]["expires_at"] = Date.strptime(params["project"]["expires_at"], '%d/%m/%Y')
  end

  def index
    index! do |format|
      format.html do
        @title = t("site.title")
        collection_projects = Project.recommended_for_home
        unless collection_projects.empty?
          if current_user and current_user.recommended_project
            @recommended_project = current_user.recommended_project
            collection_projects = collection_projects.where("id != #{current_user.recommended_project.id}").where("category_id != #{@recommended_project.category_id}")
          end
          @first_project, @second_project, @third_project, @fourth_project = collection_projects.all
        end

        project_ids = collection_projects.map{|p| p.id }
        project_ids << @recommended_project.id if @recommended_project

        @expiring = Project.expiring_for_home(project_ids)
        @recent = Project.recent_for_home(project_ids)

        @blog_posts = Blog.fetch_last_posts.inject([]) do |total,item|
          if total.size < 2
            total << item
          end
          total
        end || []

        calendar = Calendar.new
        @events = Rails.cache.fetch 'calendar', expires_in: 30.minutes do
          calendar.fetch_events_from("catarse.me_237l973l57ir0v6279rhrr1qs0@group.calendar.google.com") || []
        end
        @curated_pages = CuratedPage.visible.order("created_at desc").limit(8)
        @last_tweets = Rails.cache.fetch('last_tweets', :expires_in => 30.minutes) do
          begin
            JSON.parse(Net::HTTP.get(URI("http://api.twitter.com/1/statuses/user_timeline.json?screen_name=#{t('site.twitter')}")))[0..1]
          rescue
            []
          end
        end
        @last_tweets ||= []
      end
      format.json do
        @projects = if params[:search][:name_or_headline_or_about_or_user_name_or_user_address_city_contains]
          Project.visible.unaccent_search( params[:search][:name_or_headline_or_about_or_user_name_or_user_address_city_contains])
        else
          Project.visible.search(params[:search])
        end
        # After the search params we order by ID to avoid ties and therefore duplicate items in pagination
        respond_with(@projects.order('id').page(params[:page]).per(6))
      end
    end
  end

  def start
    return unless require_login
    @title = t('projects.start.title')
  end

  def send_mail
    current_user.update_attributes({ email: params[:contact] }) if current_user.email.nil?
    ProjectsMailer.start_project_email(
      params[:how_much_you_need],
      params[:category],
      params[:about],
      params[:rewards],
      params[:video],
      params[:facebook],
      params[:twitter],
      params[:blog],
      params[:links],
      params[:know_us_via],
      params[:contact],
      current_user,
      "#{I18n.t('site.base_url')}#{user_path(current_user)}").deliver

    # Send project receipt
    Notification.create_notification(:project_received, current_user)

    flash[:success] = t('projects.send_mail.success')
    redirect_to :root
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
    if params[:project][:permalink] == ''
      params[:project][:permalink] = nil
    end
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
      elsif resource.permalink
        return redirect_to project_by_slug_path(resource.permalink)
      end

      @project = Project.find params[:id] if params[:id].present?
      if !params[:permalink].present? and @project.permalink.present?
        return redirect_to project_by_slug_url(permalink: @project.permalink)
      end

      show!{
        @title = @project.name
        @rewards = @project.rewards.order(:minimum_value).all
        @backers = @project.backers.confirmed.limit(12).order("confirmed_at DESC").all
        fb_admins_add(@project.user.facebook_id) if @project.user.facebook_id
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

  def cep
    address = BuscaEndereco.por_cep(params[:cep])
    render :json => {
      :ok => true,
      :street => "#{address[0]} #{address[1]}",
      :neighbourhood => address[2],
      :state => address[3],
      :city => address[4]
    }.to_json
  rescue
    render :json => {:ok => false}.to_json
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

  def pending
    return unless require_admin
    @title = t('projects.pending.title')
    @search = Project.search(params[:search])
    @projects = @search.order('projects.created_at DESC').page(params[:page])
  end

  def pending_backers
    return unless require_admin
    @title = t('projects.pending_backers.title')
    @search = Backer.search(params[:search])
    @backers = @search.order("created_at DESC").page(params[:page])
  end


  private

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
    res = Net::HTTP.start("api.bit.ly", 80) { |http| http.get("/v3/shorten?login=diogob&apiKey=R_76ee3ab860d76d0d1c1c8e9cc5485ca1&longUrl=#{CGI.escape(project_url(@project))}") }
    data = JSON.parse(res.body)['data']
    data['url'] if data
  end

  def can_update_on_the_spot?
    project_fields = []
    project_admin_fields = ["name", "about", "headline", "can_finish", "expires_at", "user_id", "image_url", "video_url", "visible", "rejected", "recommended", "permalink"]
    backer_admin_fields = ["confirmed", "requested_refund", "refunded", "anonymous", "user_id"]
    reward_fields = []
    reward_admin_fields = ["description"]
    def render_error; render :text => t('require_permission'), :status => 422; end
    return render_error unless current_user
    klass, field, id = params[:id].split('__')
    return render_error unless klass == 'project' or klass == 'backer' or klass == 'reward'
    if klass == 'project'
      return render_error unless project_fields.include?(field) or (current_user.admin and project_admin_fields.include?(field))
      project = Project.find id
      return render_error unless current_user.id == project.user.id or current_user.admin
    elsif klass == 'backer'
      return render_error unless backer_fields.include?(field) or (current_user.admin and backer_admin_fields.include?(field))
      backer = Backer.find id
      return render_error unless current_user.admin or (backer.user == current_user)
    elsif klass == 'reward'
      return render_error unless reward_fields.include?(field) or (current_user.admin and reward_admin_fields.include?(field))
      reward = Reward.find id
      return render_error unless current_user.admin
    end
  end
end
