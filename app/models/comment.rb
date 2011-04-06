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
    youtube :width => 414, :height => 270
    vimeo :width => 414, :height => 270
    link :target => :_blank
  end
    
  def display_time
    "Há #{distance_of_time_in_words(created_at, Time.now)}"
  end
  
  def as_json(options={})
    {
      :id => id,
      :user => user,
      :display_time => display_time,
      :html => comment_html
    }
  end
  
end
