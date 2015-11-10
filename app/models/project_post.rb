class ProjectPost < ActiveRecord::Base
  include I18n::Alchemy
  has_notifications

  belongs_to :project, inverse_of: :posts
  belongs_to :user
  delegate :email_comment_html, to: :decorator

  before_save do
    reference_user
  end

  validates_presence_of :user_id, :project_id, :comment_html, :title

  before_validation :reference_user

  scope :ordered, ->() { order("created_at desc") }

  def reference_user
    self.user_id = self.project.try(:user_id)
  end

  def to_partial_path
    "projects/posts/project_post"
  end

  def decorator
    @decorator ||= ProjectPostDecorator.new(self)
  end
end
