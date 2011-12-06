# coding: utf-8
class ProjectsController < ApplicationController
  include ActionView::Helpers::DateHelper
  inherit_resources
  actions :index, :show, :new, :create
  respond_to :html, :except => [:backers, :comments, :updates]
  respond_to :json, :only => [:show, :backers, :comments, :updates]
  can_edit_on_the_spot
  skip_before_filter :detect_locale, :only => [:backers, :comments, :updates, :moip]
  before_filter :can_update_on_the_spot?, :only => :update_attribute_on_the_spot
  before_filter :date_format_convert, :only => [:create]
  def date_format_convert
    # TODO localize here and on the datepicker on project_form.js
    params["project"]["expires_at"] = Date.strptime(params["project"]["expires_at"], '%d/%m/%Y')
  end

  def banda
    @title = "A Banda Mais Bonita da Cidade"
    @projects = current_site.present_projects.visible.where(:user_id => 7329).order('projects_sites."order"').all
  end

  def index
    index! do
      @title = t("sites.#{current_site.path}.title")
      @home_page = current_site.present_projects.includes(:user, :category).visible.home_page.limit(6).order('projects_sites."order"').all
      @expiring = current_site.present_projects.includes(:user, :category).visible.expiring.not_home_page.not_successful.not_unsuccessful.order('expires_at, created_at DESC').limit(3).all
      @recent = current_site.present_projects.includes(:user, :category).visible.not_home_page.not_expiring.not_successful.not_unsuccessful.where("projects.user_id <> 7329").order('created_at DESC').limit(3).all
      @successful = current_site.present_projects.includes(:user, :category).visible.not_home_page.successful.order('expires_at DESC').limit(3).all
      @curated_pages = current_site.curated_pages.visible.order("created_at desc").limit(6)
    end
  end
  def explore
    @title = t('projects.explore.title')
    @categories = Category.with_projects(current_site).order(:name).all
    @recommended = current_site.present_projects.visible.recommended.order('created_at DESC').all
    @expiring = current_site.present_projects.visible.expiring.limit(16).order('expires_at').all
    @recent = current_site.present_projects.visible.recent.limit(16).order('created_at DESC').all
    @successful = current_site.present_projects.visible.successful.order('expires_at DESC').all
    @all = current_site.present_projects.visible.order('created_at DESC').all
  end
  def start
    @title = t('projects.start.title')
  end
  def send_mail
    current_user.update_attribute :email, params[:contact] if current_user.email.nil?
    ProjectsMailer.start_project_email(params[:about], params[:rewards], params[:links], params[:contact], current_user, current_site).deliver
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
    validate_rewards_attributes if params[:project][:rewards_attributes].present?
    create!(:notice => t('projects.create.success'))
    # When don't create the project the @project don't exists so causes a record not found
    # because @project.reload *words only with created records*
    unless @project.new_record?
      @project.reload
      @project.update_attribute :short_url, bitly
      @project.projects_sites.create :site => current_site
    end
  end
  def show
    show!{
      unless @project.present_on_site?(current_site)
        flash[:failure] = t('projects.show.not_present')
        return redirect_to :root
      end
      @title = @project.name
      @rewards = @project.rewards.order(:minimum_value).all
      @backers = @project.backers.confirmed.limit(12).order("confirmed_at DESC").all
      @updates = @project.updates.all
      @update = @project.comments.new :project_update => true
      @comments = @project.comments.all
      @comment = @project.comments.new
    }
  end
  def guidelines
    @title = t('projects.guidelines.title', :site => current_site.the_name)
  end
  def faq
    @title = t('projects.faq.title')
  end
  def terms
    @title = t('projects.terms.title')
  end
  def privacy
    @title = t('projects.privacy.title')
  end
  def vimeo
    project = Project.new(:video_url => params[:url])
    if project.vimeo
      render :json => project.vimeo.to_json
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
  def back
    return unless require_login
    show! do
      unless @project.can_back?(current_site)
        flash[:failure] = t('projects.back.cannot_back')
        return redirect_to :root
      end
      @title = t('projects.back.title', :name => @project.name)
      @backer = @project.backers.new(:user => current_user, :site => current_site)
      empty_reward = Reward.new(:id => 0, :minimum_value => 0, :description => t('projects.back.no_reward'))
      @rewards = [empty_reward] + @project.rewards.order(:minimum_value)
      @reward = @project.rewards.find params[:reward_id] if params[:reward_id]
      @reward = nil if @reward and @reward.sold_out?
      if @reward
        @backer.reward = @reward
        @backer.value = "%0.0f" % @reward.minimum_value
      end
    end
  end
  def review
    @title = t('projects.review.title')
    params[:backer][:reward_id] = nil if params[:backer][:reward_id] == '0'
    params[:backer][:user_id] = current_user.id
    params[:backer][:site_id] = current_site.id
    @project = Project.find params[:id]
    @backer = @project.backers.new(params[:backer])
    unless @backer.save
      flash[:failure] = t('projects.review.error')
      return redirect_to back_project_path(@project)
    end
    session[:thank_you_id] = @project.id
  end
  def pay
    backer = Backer.find params[:backer_id]
    if backer.credits
      if current_user.credits < backer.value
        flash[:failure] = t('projects.pay.no_credits')
        return redirect_to back_project_path(backer.project)
      end
      unless backer.confirmed
        current_user.update_attribute :credits, current_user.credits - backer.value
        backer.update_attribute :payment_method, 'Credits'
        backer.confirm!
      end
      flash[:success] = t('projects.pay.success')
      redirect_to thank_you_path
    else
      begin
        current_user.update_attributes params[:user]
        current_user.reload
        payer = {
          :nome => current_user.full_name,
          :email => current_user.email,
          :logradouro => current_user.address_street,
          :numero => current_user.address_number,
          :complemento => current_user.address_complement,
          :bairro => current_user.address_neighbourhood,
          :cidade => current_user.address_city,
          :estado => current_user.address_state,
          :pais => "BRA",
          :cep => current_user.address_zip_code,
          :tel_fixo => current_user.phone_number
        }
        payment = {
          :valor => "%0.0f" % (backer.value),
          :id_proprio => backer.key,
          :razao => "Apoio para o projeto '#{backer.project.name}'",
          :forma => "BoletoBancario",
          :dias_expiracao => 2,
          :pagador => payer,
          :url_retorno => thank_you_url
        }
        response = MoIP::Client.checkout(payment)
        backer.update_attribute :payment_token, response["Token"]
        session[:_payment_token] = response["Token"]
        redirect_to MoIP::Client.moip_page(response["Token"])
      rescue
        flash[:failure] = t('projects.pay.moip_error')
        return redirect_to back_project_path(backer.project)
      end
    end
  end

  def backers
    @project = Project.find params[:id]
    @backers = @project.backers.confirmed.order("confirmed_at DESC").paginate :page => params[:page], :per_page => 10
    render :json => @backers.to_json(:can_manage => can?(:manage, @project))
  end
  
  def comments
    @project = Project.find params[:id]
    @comments = @project.comments.order("created_at DESC").paginate :page => params[:page], :per_page => 5
    respond_with @comments
  end
  
  def updates
    @project = Project.find params[:id]
    @updates = @project.updates.order("created_at DESC").paginate :page => params[:page], :per_page => 3
    respond_with @updates
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
    @search = current_site.projects_sites.includes(:project).search(params[:search])
    @projects_sites = @search.order('projects.created_at DESC').paginate :page => params[:page]
  end
  def pending_backers
    return unless require_admin
    @title = t('projects.pending_backers.title')
    @search = Backer.search(params[:search])
    @backers = @search.order("created_at DESC").paginate :page => params[:page]
    @total_backers = User.backers.count
    @total_backs = Backer.confirmed.count
    @total_backed = Backer.confirmed.sum(:value)
    @total_users = User.primary.count
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
    project_admin_fields = ["name", "about", "headline", "can_finish", "expires_at", "user_id", "image_url", "video_url"]
    projects_site_fields = []
    projects_site_admin_fields = ["visible", "rejected", "recommended", "home_page", "order"]
    backer_fields = ["display_notice"]
    backer_admin_fields = ["confirmed", "requested_refund", "refunded", "anonymous", "user_id"]
    reward_fields = []
    reward_admin_fields = ["description"]
    def render_error; render :text => t('require_permission'), :status => 422; end
    return render_error unless current_user
    klass, field, id = params[:id].split('__')
    return render_error unless klass == 'project' or klass == 'projects_site' or klass == 'backer' or klass == 'reward'
    if klass == 'project'
      return render_error unless project_fields.include?(field) or (current_user.admin and project_admin_fields.include?(field))
      project = Project.find id
      return render_error unless current_user.id == project.user.id or current_user.admin
    elsif klass == 'projects_site'
      return render_error unless projects_site_fields.include?(field) or (current_user.admin and projects_site_admin_fields.include?(field))
      project_site = current_site.projects_sites.find id
      return render_error unless current_user.id == project_site.project.user.id or current_user.admin
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
