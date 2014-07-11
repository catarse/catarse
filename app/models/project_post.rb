class ProjectPost < ActiveRecord::Base
  include Shared::CatarseAutoHtml

  has_notifications

  belongs_to :project, inverse_of: :posts
  belongs_to :user

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
      notify_once(:posts, user, self, {from_email: project.user.email, from_name: project.user.display_name})
    end
  end

  def to_partial_path
    "projects/posts/project_post"
  end
end
