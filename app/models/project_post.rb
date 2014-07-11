class ProjectPost < ActiveRecord::Base
  include Shared::CatarseAutoHtml

  schema_associations
  has_many :notifications, dependent: :destroy
  validates_presence_of :user_id, :project_id, :comment, :comment_html
  #remove all whitespace from the start of the line so auto_html won't go crazy
  before_save -> {self.comment = comment.gsub(/^[^\S\n]+/, "")}

  catarse_auto_html_for field: :comment, video_width: 560, video_height: 340

  scope :for_non_contributors, ->() {
    where("not exclusive")
  }

  scope :ordered, ->() { order("created_at desc") }

  def post_number
    self.project.posts.where('id <= ?', self.id).count(:all)
  end

  def email_comment_html
    catarse_email_auto_html_for comment, image_width: 513
  end

  def notify_contributors
    project.subscribed_users.each do |user|
      Notification.notify_once(
        :posts,
        user,
        {project_post_id: self.id, user_id: user.id},
        {
          project: project,
          project_post: self,
          origin_email: project.user.email,
          origin_name: project.user.display_name
        }
      )
    end
  end

  def to_partial_path
    "projects/posts/project_post"
  end
end
