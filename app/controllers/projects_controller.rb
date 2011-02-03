# coding: utf-8
class ProjectsController < ApplicationController
  inherit_resources
  actions :index, :show, :new, :create, :edit, :update
  can_edit_on_the_spot
  before_filter :can_update_on_the_spot?, :only => :update_attribute_on_the_spot
  before_filter :date_format_convert, :only => [:create, :update]
  def date_format_convert
    params["project"]["expires_at"] = Date.strptime(params["project"]["expires_at"], '%d/%m/%Y')
  end

  def teaser
    @title = "Faça acontecer os projetos em que você acredita"
    if params[:status] == "success"
      flash.now[:success] = "Pronto. Agora é só verificar sua caixa de entrada e confirmar o cadastro. Muito obrigado!"
    elsif params[:status] == "failure"
      flash.now[:failure] = "Ooops. Ocorreu um erro ao adicionar seu email em nossa lista. Por favor, tente novamente."
    end
    render :layout => 'teaser'
  end
  def index
    index! do
      @title = "A primeira plataforma de financiamento colaborativo de projetos criativos do Brasil"
      @projects = Project.visible.order('"order", created_at DESC')
    end
  end
  def new
    return unless require_login
    new! do
      @title = "Envie seu projeto"
      @project.rewards.build
    end
  end
  def create
    create!(:notice => "Seu projeto foi criado com sucesso! Logo avisaremos se ele foi selecionado. Muito obrigado!")
    @project.update_attribute :short_url, bitly
  end
  def update
    update!(:notice => "Seu projeto foi atualizado com sucesso!")
  end
  def show
    show!{
      @title = @project.name
      @rewards = @project.rewards.order(:minimum_value)
      @backers = @project.backers.confirmed.limit(12).order(:confirmed_at)
    }
  end
  def guidelines
    @title = "Como funciona o Catarse"
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
  def back
    return unless require_login
    show! do
      @title = "Apoie o #{@project.name}"
      @backer = @project.backers.new(:user_id => current_user.id)
      empty_reward = Reward.new(:id => 0, :minimum_value => 0, :description => "Obrigado. Eu só quero ajudar o projeto.")
      @rewards = [empty_reward] + @project.rewards.order(:minimum_value)
    end
  end
  def review
    params[:backer][:reward_id] = nil if params[:backer][:reward_id] == '0'
    params[:backer][:user_id] = current_user.id
    @project = Project.find params[:id]
    @backer = @project.backers.new(params[:backer])
    unless @backer.save
      flash[:failure] = "Ooops. Ocorreu um erro ao registrar seu apoio. Por favor, tente novamente."
      return redirect_to back_project_path(project)
    end
    session[:thank_you_id] = @project.id
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
    MoipMailer.payment_received_email(nil, params).deliver
    id = params[:id_transacao]
    status = params[:status_pagamento]
    value = params[:valor]
    backer = Backer.find id
    MoipMailer.payment_received_email(backer, params).deliver
    return render :nothing => true, :status => 200 if status != '1'
    return render :nothing => true, :status => 200 if backer.confirmed
    return render :nothing => true, :status => 422 if backer.moip_value != value
    backer.confirm!
    return render :nothing => true, :status => 200
  rescue => e
    MoipMailer.error_in_payment_email(backer, params, e).deliver
    return render :nothing => true, :status => 422
  end
  def backers
    show! do
      @title = "Apoiadores do projeto #{@project.name}"
      @rewards = @project.rewards.order(:minimum_value)
      @backers = @project.backers.confirmed.order(:confirmed_at)
    end
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
    @projects = Project.order('visible, rejected, "order", created_at DESC').all
  end
  def pending_backers
    return unless require_admin
    @backers = Backer.order("confirmed, created_at DESC").all
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
    project_admin_fields = ["visible", "rejected", "about"]
    backer_fields = []
    backer_admin_fields = ["confirmed"]
    reward_fields = []
    reward_admin_fields = ["description"]
    def render_error; render :text => 'Você não possui permissão para realizar esta ação.', :status => 422; end
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
      return render_error unless current_user.admin
    elsif klass == 'reward'
      return render_error unless reward_fields.include?(field) or (current_user.admin and reward_admin_fields.include?(field))
      reward = Reward.find id
      return render_error unless current_user.admin
    end
  end
end

