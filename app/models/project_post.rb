class ProjectPost < ActiveRecord::Base
  include Shared::CatarseAutoHtml

  has_notifications

  belongs_to :project, inverse_of: :posts
  belongs_to :user

  validates_presence_of :user_id, :project_id, :comment, :comment_html
  #remove all whitespace from the start of the line so auto_html won't go crazy
  before_save -> {self.comment = comment.gsub(/^[^\S\n]+/, "")}

  catarse_auto_html_for field: :comment, video_width: 560, video_height: 340

  scope :ordered, ->() { order("created_at desc") }

  def email_comment_html
    catarse_email_auto_html_for comment, image_width: 513
  end

  def to_partial_path
    "projects/posts/project_post"
  end
end
