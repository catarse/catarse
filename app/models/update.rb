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
end
