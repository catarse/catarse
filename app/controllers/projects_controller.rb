# coding: utf-8
class ProjectsController < ApplicationController
  inherit_resources
  actions :index, :show, :new, :create, :edit, :update
  def index
    index!{ @title = "Faça acontecer os projetos em que você acredita" }
  end
  def new
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
    show!{ @title = @project.name }
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
    show! do
      @title = "Apoie o #{@project.name}"
      @backer = @project.backers.new(:user_id => current_user.id)
      @empty_reward = Reward.new(:id => -1, :minimum_value => 0, :description => "Obrigado. Eu só quero ajudar o projeto.")
    end
  end
end
