# coding: utf-8

class Post
  
  attr_accessor :id, :title, :body, :project_id, :curated_page_id
  attr_reader :project
  attr_reader :curated_page
  include ActiveModel::Conversion
  extend ActiveModel::Naming
  include ActiveModel::AttributeMethods
  include AutoHtml

  def persisted?
    false
  end

  def initialize params
    @title, @body, @project_id, @curated_page_id = [params[:title], params[:body], params[:project_id], params[:curated_page_id]]
    @project = Project.find(@project_id) if @project_id
    @curated_page = CuratedPage.find(@curated_page_id) if @curated_page_id
  end
  
  def save
    @body = auto_html(@body) do
      html_escape :map => { 
        '&' => '&amp;',  
        '>' => '&gt;',
        '<' => '&lt;',
        '"' => '"' }
      redcloth :target => :_blank
      image
      youtube :width => 560, :height => 365
      vimeo :width => 560, :height => 365
      link :target => :_blank
    end
    if @project
      tags = "project_post,project_#{@project.id}"
    elsif @curated_page
      tags = "curated_page_post,curated_page_#{@curated_page.id}"
    end
    @id = Tumblr::Post.create(TumblrUser, group: Configuration[:tumblr_blog], title: @title, body: @body, tags: tags).body
  end
  
  def self.all(options = {})
    project = options[:project]
    curated_page = options[:curated_page]
    type = (options[:type] || :platform).to_sym
    per_page = (options[:per_page] || 4).to_i
    page = (options[:page] || 1).to_i
    start = (page-1) * per_page
    params = {start: start, num: per_page, type: :text}
    if project
      type = :project
      params[:tagged] = "project_#{project.id}"
    elsif curated_page
      type = :curated_page
      params[:tagged] = "curated_page_#{curated_page.id}"
    elsif type == :projects
      params[:tagged] = "project_post"
    elsif type == :curated_pages
      params[:tagged] = "curated_page_post"
    end
    raise params.inspect
    posts = Tumblr::Post.all(params).delete_if(&:nil?) || [] #rescue []
    if type == :platform
      posts = posts.delete_if do |post|
        post["tag"].include?("project_post") || post["tag"].include?("curated_page_post") rescue false
      end
    end
    posts
  end
  
end
