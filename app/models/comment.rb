class Comment < ActiveRecord::Base

  include ActsAsCommentable::Comment

  belongs_to :commentable, :polymorphic => true
  belongs_to :user
  validates_presence_of :comment, :commentable, :user
  default_scope :order => 'created_at ASC'
  scope :updates, where(:project_update => true)
  scope :not_updates, where(:project_update => true)

  acts_as_commentable

  auto_html_for :comment do
    html_escape :map => { 
      '&' => '&amp;',  
      '>' => '&gt;',
      '<' => '&lt;',
      '"' => '"' }
    redcloth :target => :_blank
    image
    youtube :width => 460, :height => 300
    vimeo :width => 460, :height => 300
    link :target => :_blank
  end
    
end
