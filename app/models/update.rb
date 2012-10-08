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
      Notification.create_notification :updates, backer.user,
        :project_name => backer.project.name,
        :project_owner => backer.project.user.display_name,
        :update_title => title,
        :update => self,
        :update_comment =>  (auto_html(comment) { link; redcloth; } )
    end
  end

end
