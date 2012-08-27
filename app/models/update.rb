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
    youtube width: 640, height: 430, wmode: "opaque"
    vimeo width: 640, height: 430
    redcloth :target => :_blank
    link :target => :_blank
  end

  def notify_backers
    project.backers.confirmed.each do |backer|
      text = I18n.t('notifications.updates.text',
                    :update_title => title,
                    :update_text => auto_html(comment) { link; redcloth; },
                    :project_link => Rails.application.routes.url_helpers.project_url(project, :host => I18n.t('site.host')),
                    :project_name => project.name)
      Notification.create! :user => backer.user,
                           :email_subject => I18n.t('notifications.updates.subject',
                                                    :project_name => project.name,
                                                    :project_owner => project.user.display_name,
                                                    :update_title => title),
                           :email_text => text,
                           :text => text
    end
  end

end
