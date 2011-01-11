# coding: utf-8
class ProjectsController < ApplicationController
  inherit_resources
  actions :index, :show, :new, :create, :edit, :update
  def teaser
    @title = "Faça acontecer os projetos em que você acredita"
    if params[:status] == "success"
      flash.now[:success] = "Seu email foi adicionado com sucesso em nossa lista. Muito obrigado!"
    elsif params[:status] == "failure"
      flash.now[:failure] = "Ooops. Ocorreu um erro ao adicionar seu email em nossa lista. Por favor, tente novamente."
    end
    render :layout => 'teaser'
  end
  def index
    index! do
      @title = "Faça acontecer os projetos em que você acredita"
      @projects = Project.visible
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
  end
  def update
    update!(:notice => "Seu projeto foi atualizado com sucesso!")
  end
  def show
    show!{
      @title = @project.name
      @rewards = @project.rewards.order(:minimum_value)
      @backers = @project.backers.confirmed.limit(6).order(:confirmed_at)
    }
  end
  def guidelines
    @title = "Como funciona o Catarse"
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
      redirect_to back_project_path(project)
    end
  end
  def thank_you
    show! do
      @title = "Muito obrigado"
    end
  end
  def backers
    show! do
      @title = "Apoiadores do projeto #{@project.name}"
      @rewards = @project.rewards.order(:minimum_value)
      @backers = @project.backers.confirmed.order(:confirmed_at)
    end
  end
end
