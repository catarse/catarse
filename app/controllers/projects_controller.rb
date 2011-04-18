# coding: utf-8
class ProjectsController < ApplicationController
  include ActionView::Helpers::DateHelper
  inherit_resources
  actions :index, :show, :new, :create, :edit, :update
  respond_to :html, :except => [:backers, :comments, :updates]
  respond_to :json, :only => [:show, :backers, :comments, :updates]
  can_edit_on_the_spot
  skip_before_filter :verify_authenticity_token, :only => [:moip]
  before_filter :can_update_on_the_spot?, :only => :update_attribute_on_the_spot
  before_filter :date_format_convert, :only => [:create, :update]
  def date_format_convert
    params["project"]["expires_at"] = Date.strptime(params["project"]["expires_at"], '%d/%m/%Y')
  end

  def index
    index! do
      @title = current_site.title
      @recommended = current_site.present_projects.visible.home_page.limit(6).order('projects_sites."order"').all
      @recent = current_site.present_projects.visible.not_home_page.not_successful.not_unsuccessful.order('created_at DESC').limit(12).all
      @successful = current_site.present_projects.visible.not_home_page.successful.order('expires_at DESC').limit(12).all
    end
  end
  def explore
    @title = "Explore os projetos"
    @categories = Category.with_projects(current_site).order(:name)
    @recommended = current_site.present_projects.visible.recommended.order('created_at DESC')
    @expiring = current_site.present_projects.visible.expiring.order('expires_at')
    @recent = current_site.present_projects.visible.recent.order('created_at DESC')
    @successful = current_site.present_projects.visible.successful.order('expires_at DESC')
    @all = current_site.present_projects.visible.order('created_at DESC')
  end
  def start
    @title = "Envie seu projeto"
  end
  def send_mail
    current_user.update_attribute :email, params[:contact] if current_user.email.nil?
    ProjectsMailer.start_project_email(params[:about], params[:rewards], params[:links], params[:contact], current_user, current_site).deliver
    flash[:success] = "Seu projeto foi enviado com sucesso! Logo entraremos em contato. Muito obrigado!"
    redirect_to :root
  end
  def new
    return unless require_login
    new! do
      @title = "Envie seu projeto"
      @project.rewards.build
    end
  end
  def create
    params[:project][:expires_at] += (23.hours + 59.minutes + 59.seconds) if params[:project][:expires_at]
    create!(:notice => "Seu projeto foi criado com sucesso! Logo avisaremos se ele foi selecionado. Muito obrigado!")
    @project.reload
    @project.update_attribute :short_url, bitly
    @project.projects_sites.create :site => current_site
  end
  def update
    update!(:notice => "Seu projeto foi atualizado com sucesso!")
  end
  def show
    show!{
      unless @project.present?(current_site)
        flash[:failure] = "Este projeto não está disponível neste site. Confira os outros projetos incríveis que temos!"
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
    @title = "Como funciona #{current_site.the_name}"
  end
  def faq
    @title = "Perguntas frequentes"
  end
  def terms
    @title = "Termos de uso"
  end
  def privacy
    @title = "Política de privacidade"
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
        flash[:failure] = "Não é possível apoiar este projeto no momento. Por favor, apoie outros projetos."
        return redirect_to :root
      end
      @title = "Apoie o #{@project.name}"
      @backer = @project.backers.new(:user => current_user, :site => current_site)
      empty_reward = Reward.new(:id => 0, :minimum_value => 0, :description => "Obrigado. Eu só quero ajudar o projeto.")
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
    @title = "Preencha e revise seus dados"
    params[:backer][:reward_id] = nil if params[:backer][:reward_id] == '0'
    params[:backer][:user_id] = current_user.id
    params[:backer][:site_id] = current_site.id
    @project = Project.find params[:id]
    @backer = @project.backers.new(params[:backer])
    unless @backer.save
      flash[:failure] = "Ooops. Ocorreu um erro ao registrar seu apoio. Por favor, tente novamente."
      return redirect_to back_project_path(project)
    end
    session[:thank_you_id] = @project.id
  end
  def pay
    backer = Backer.find params[:backer_id]
    if backer.credits
      if current_user.credits < backer.value
        flash[:failure] = "Você não possui créditos suficientes para realizar este apoio."
        return redirect_to back_project_path(backer.project)
      end
      unless backer.confirmed
        current_user.update_attribute :credits, current_user.credits - backer.value
        backer.confirm!
      end
      flash[:success] = "Seu apoio foi realizado com sucesso. Muito obrigado!"
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
          :pagador => payer
        }
        response = MoIP::Client.checkout(payment)
        redirect_to MoIP::Client.moip_page(response["Token"])
      rescue
        flash[:failure] = "Ooops. Ocorreu um erro ao enviar seu pagamento para o MoIP. Por favor, tente novamente."
        return redirect_to back_project_path(backer.project)
      end
    end
  end
  def thank_you
    unless session[:thank_you_id]
      flash[:failure] = "Ooops. Você só pode acessar esta página depois de apoiar um projeto."
      return redirect_to :root
    end
    @project = Project.find session[:thank_you_id]
    @title = "Muito obrigado"
    session[:thank_you_id] = nil
  end
  def moip
    key = params[:id_transacao]
    status = params[:status_pagamento]
    value = params[:valor]
    backer = Backer.find_by_key key
    return render :nothing => true, :status => 200 if status != '1'
    return render :nothing => true, :status => 200 if backer.confirmed
    return render :nothing => true, :status => 422 if backer.moip_value != value
    backer.confirm!
    return render :nothing => true, :status => 200
  rescue => e
    return render :nothing => true, :status => 422
  end
  def backers
    @project = Project.find params[:id]
    @backers = @project.backers.confirmed.order("confirmed_at DESC").paginate :page => params[:page], :per_page => 10
    respond_with @backers
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
    @title = "Gerenciamento dos projetos"
    @search = current_site.projects_sites.includes(:project).search(params[:search])
    @projects_sites = @search.order('projects.created_at DESC').paginate :page => params[:page]
  end
  def pending_backers
    return unless require_admin
    @title = "Gerenciamento de apoios"
    @search = Backer.search(params[:search])
    @backers = @search.order("created_at DESC").paginate :page => params[:page]
    @total_backers = User.backers.count
    @total_backs = Backer.confirmed.count
    @total_pledged = Backer.confirmed.sum(:value)
    @total_users = User.primary.count
  end
  private
  def bitly
    require 'net/http'
    res = Net::HTTP.start("api.bit.ly", 80) { |http| http.get("/v3/shorten?login=diogob&apiKey=R_76ee3ab860d76d0d1c1c8e9cc5485ca1&longUrl=#{CGI.escape(project_url(@project))}") }
    data = JSON.parse(res.body)['data']
    data['url'] if data
  end
  def can_update_on_the_spot?
    project_fields = []
    project_admin_fields = ["name", "about", "headline", "can_finish", "expires_at", "user_id", "image_url"]
    projects_site_fields = []
    projects_site_admin_fields = ["visible", "rejected", "recommended", "home_page", "order"]
    backer_fields = ["display_notice"]
    backer_admin_fields = ["confirmed", "requested_refund", "refunded"]
    reward_fields = []
    reward_admin_fields = ["description"]
    def render_error; render :text => 'Você não possui permissão para realizar esta ação.', :status => 422; end
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
