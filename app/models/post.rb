# coding: utf-8

class Post
  attr_accessor :id, :title, :body, :project_id
  attr_reader :project
  include ActiveModel::Conversion
  extend ActiveModel::Naming
  include ActiveModel::AttributeMethods
  # include ActiveModel::Validations
  def persisted?
    false
  end
  def initialize params
    @title, @body, @project_id = [params[:title], params[:body], params[:project_id]]
    @project = Project.find(@project_id) if @project_id
  end
  def save
    @id = Tumblr::Post.create(TumblrUser, group: Configuration[:tumblr_blog], title: @title, body: @body, tags: @project.to_param).body
  end
  def self.all(project)
    Tumblr::Post.all(:tagged => project.to_param).delete_if(&:nil?) || [] rescue []
  end
end
