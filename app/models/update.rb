class Update < ActiveRecord::Base
  belongs_to :user
  belongs_to :project
  validates_presence_of :user_id, :project_id, :comment, :comment_html

  auto_html_for :comment do
    html_escape :map => {
      '&' => '&amp;',
      '>' => '&gt;',
      '<' => '&lt;',
      '"' => '"' }
    image
    youtube width: 560, height: 340, wmode: "opaque"
    vimeo width: 560, height: 340
    redcloth :target => :_blank
    link :target => :_blank
  end

  def email_comment_html
    auto_html(comment) do
      html_escape :map => {
        '&' => '&amp;',
        '>' => '&gt;',
        '<' => '&lt;',
        '"' => '"' 
      }
      image
      redcloth :target => :_blank
      link :target => :_blank
    end
  end

  def notify_backers
    project.subscribed_users.each do |user|
      Rails.logger.info "[User #{user.id}] - Creating notification for #{user.name}"
      Notification.create_notification :updates, user,
        :project_name => project.name,
        :project_owner => project.user.display_name,
        :update_title => title,
        :update => self,
        :update_comment => email_comment_html
    end
  end

end
