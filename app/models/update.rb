class Update < ActiveRecord::Base
  extend CatarseAutoHtml

  schema_associations
  has_many :notifications, dependent: :destroy
  validates_presence_of :user_id, :project_id, :comment, :comment_html
  before_save -> {self.comment = comment.gsub(/^\s+/, "")}

  catarse_auto_html_for field: :comment, video_width: 560, video_height: 340

  def email_comment_html
    auto_html(comment) do
      html_escape map: {
        '&' => '&amp;',
        '>' => '&gt;',
        '<' => '&lt;',
        '"' => '"'
      }
      email_image width: 513
      redcloth target: :_blank
      link target: :_blank
    end
  end

  def notify_backers
    project.subscribed_users.each do |user|
      Rails.logger.info "[User #{user.id}] - Creating notification for #{user.name}"
      Notification.create_notification_once :updates, user,
        {update_id: self.id, user_id: user.id},
        update_id: self.id,
        project_name: project.name,
        project_owner: project.user.display_name,
        project_owner_email: project.user.email,
        from: project.user.email,
        display_name: project.user.display_name,
        update_title: title,
        update: self,
        from: project.user.email,
        display_name: project.user.display_name,
        update_comment: email_comment_html
    end
  end

end
