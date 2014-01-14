class ChannelPost < ActiveRecord::Base
  extend CatarseAutoHtml

  schema_associations

  validates_presence_of :user_id, :channel_id, :body, :body_html
  #remove all whitespace from the start of the line so auto_html won't go crazy
  before_save -> {self.body = body.gsub(/^[^\S\n]+/, "")}

  catarse_auto_html_for field: :body, video_width: 560, video_height: 340

  scope :ordered, -> { order('id desc') }

  def to_s
    self.title
  end
end
