class ProjectsController < ApplicationController
  inherit_resources
  actions :index, :show, :new, :create
  def index
    index!{ @title = t 'projects.index.title' }
  end
  def new
    new!{ @title = "Envie seu projeto" }
  end
  def create
    create!(:notice => "Seu projeto foi criado com sucesso! Em breve entraremos em contato para avisar se ele foi selecionado. Muito obrigado!")
  end
  def show
    show!{ @title = @project.name }
  end
  def guidelines
    @title = "Envie seu projeto"
  end
  def vimeo
    project = Project.new(:video_url => params[:url])
    if project.vimeo
      render :json => project.vimeo.to_json
    else
      render :json => {:id => false}.to_json
    end
  end
end
