class Comment < ActiveRecord::Base

  include ActionView::Helpers::DateHelper
  include ActsAsCommentable::Comment

  belongs_to :commentable, :polymorphic => true
  belongs_to :user
  validates_presence_of :comment, :commentable, :user

  acts_as_commentable

  auto_html_for :comment do
    html_escape :map => { 
      '&' => '&amp;',  
      '>' => '&gt;',
      '<' => '&lt;',
      '"' => '"' }
    redcloth :target => :_blank
    image
    youtube :width => 580, :height => 378
    vimeo :width => 580, :height => 378
    link :target => :_blank
  end
    
  def display_time
    I18n.t('comment.display_time', :time_ago => time_ago_in_words(created_at))
  end
  
  def as_json(options={})
    {
      :id => id,
      :user => user,
      :display_time => display_time,
      :title => title,
      :html => comment_html
    }
  end
  
end
