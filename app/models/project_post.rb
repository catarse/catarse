# frozen_string_literal: true

class ProjectPost < ApplicationRecord
  include I18n::Alchemy
  include Shared::CommonWrapper
  has_notifications

  belongs_to :project, inverse_of: :posts
  belongs_to :reward, optional: true
  belongs_to :user
  delegate :email_comment_html, to: :decorator
  has_many :post_rewards, dependent: :delete_all

  before_save do
    reference_user
  end
  after_save :index_on_common

  validates_presence_of :user_id, :project_id, :comment_html, :title

  before_validation :reference_user

  scope :ordered, ->() { order('created_at desc') }

  def reference_user
    self.user_id = project.try(:user_id)
  end

  def to_partial_path
    'projects/posts/project_post'
  end

  def decorator
    @decorator ||= ProjectPostDecorator.new(self)
  end

  def common_index
    id_hash = common_id.present? ? {id: common_id} : {}

    {
      external_id: id,
      project_id: project.common_id,
      reward_id: reward.try(:common_id),
      current_ip: project.user.current_sign_in_ip,
      comment_html: comment_html,
      title: title,
      exclusive: exclusive,
      recipients: recipients,
      created_at: created_at.try(:strftime, "%FT%T")
    }.merge!(id_hash)
  end

  def index_on_common
    common_wrapper.index_project_post(self) if common_wrapper
  end
end
