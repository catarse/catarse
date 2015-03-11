class ProjectPost < ActiveRecord::Base

  has_notifications

  belongs_to :project, inverse_of: :posts
  belongs_to :user
  before_save do
    reference_user
  end

  validates_presence_of :user_id, :project_id, :comment_html

  before_validation :reference_user

  scope :ordered, ->() { order("created_at desc") }

  def reference_user
    self.user_id = self.project.try(:user_id)
  end

  def to_partial_path
    "projects/posts/project_post"
  end
end
