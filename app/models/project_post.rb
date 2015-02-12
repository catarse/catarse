class ProjectPost < ActiveRecord::Base
  include Shared::CatarseAutoHtml

  has_notifications

  belongs_to :project, inverse_of: :posts
  belongs_to :user

  validates_presence_of :user_id, :project_id, :comment, :comment_html
  #remove all whitespace from the start of the line so auto_html won't go crazy
  before_save do
    self.comment = comment.gsub(/^[^\S\n]+/, "")
    reference_user
  end

  before_validation :reference_user

  catarse_auto_html_for field: :comment, video_width: 560, video_height: 340

  scope :ordered, ->() { order("created_at desc") }

  def email_comment_html
    catarse_auto_html comment, image_width: 513
  end

  def reference_user
    self.user_id = self.project.try(:user_id)
  end

  def to_partial_path
    "projects/posts/project_post"
  end
end
