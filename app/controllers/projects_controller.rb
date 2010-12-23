# coding: utf-8
class ProjectsController < ApplicationController
  inherit_resources
  actions :index, :show, :new, :create, :edit, :update
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
    # TODO remove the next lines
    @backer.confirmed = true
    @backer.confirmed_at = Time.now
    # TODO until here
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
end
