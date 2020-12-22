# coding: utf-8
# frozen_string_literal: true

class Reward < ApplicationRecord
  include I18n::Alchemy
  include RankedModel
  include ERB::Util
  include Shared::CommonWrapper

  before_destroy :check_if_is_destroyable

  belongs_to :project
  has_many :contributions, dependent: :nullify
  has_many :payments, through: :contributions
  has_many :shipping_fees, dependent: :destroy
  has_one :survey
  has_one :reward_metric_storage, dependent: :destroy

  mount_uploader :uploaded_image, RewardUploader

  accepts_nested_attributes_for :shipping_fees, allow_destroy: true
  ranks :row_order, with_same: :project_id

  validates_presence_of :minimum_value, :description, :deliver_at, :shipping_options # , :days_to_delivery
  validates_numericality_of :minimum_value,
    greater_than_or_equal_to: 10.00,
    message: 'Valor deve ser maior ou igual a R$ 10',
    if: ->{ project && !project.is_sub? }

  validates_numericality_of :minimum_value,
    greater_than_or_equal_to: 5.00,
    message: 'Valor deve ser maior ou igual a R$ 5',
    if: -> { project && project.is_sub? }

  validates_numericality_of :maximum_contributions, only_integer: true, greater_than: 0, allow_nil: true
  scope :remaining, -> {
    where("
             rewards.maximum_contributions IS NULL
             OR (
              rewards.maximum_contributions IS NOT NULL
              AND (
                    SELECT
                    COUNT(distinct c.id)
                    FROM
                      contributions c JOIN payments p ON p.contribution_id = c.id
                    WHERE
                      (p.state = 'paid' OR
                      p.waiting_payment)
                      AND reward_id = rewards.id
                  ) < maximum_contributions)")
  }
  scope :sort_asc, -> { order('id ASC') }

  delegate :display_deliver_estimate, :display_remaining, :name, :display_minimum, :short_description,
           :medium_description, :last_description, :display_description, :display_label, to: :decorator

  before_save :log_changes
  after_save :expires_project_cache
  after_save :index_on_common

  def log_changes
    self.last_changes = changes
  end

  def to_s
    display_description
  end

  def decorator
    @decorator ||= RewardDecorator.new(self)
  end

  def sold_out?
    # maximum_contributions && total_compromised >= maximum_contributions
    pluck_from_database('sold_out')
  end

  def any_sold?
    total_compromised > 0
  end

  def total_contributions(states = %w[paid pending])
    payments.with_states(states).count('DISTINCT contributions.id')
  end

  def total_compromised
    paid_count + in_time_to_confirm
  end

  def refresh_reward_metric_storage
    pluck_from_database('refresh_reward_metric_storage')
  end

  def paid_count
    pluck_from_database('paid_count')
  end

  def in_time_to_confirm
    pluck_from_database('waiting_payment_count')
  end

  def remaining
    return nil unless maximum_contributions
    maximum_contributions - total_compromised
  end

  def check_if_is_destroyable
    if any_sold?
      project.errors.add 'reward.destroy', "can't destroy"
      throw :abort
    end
  end

  def expires_project_cache
    project.expires_fragments 'project-rewards'
  end

  def common_index
    id_hash = common_id.present? ? {id: common_id} : {}

    {
      external_id: id,
      project_id: project.common_id,
      minimum_value: (minimum_value*100),
      maximum_contributions: maximum_contributions || 0,
      shipping_options: shipping_options,
      deliver_at: deliver_at.try(:strftime, "%FT%T"),
      row_order: row_order,
      title: title,
      welcome_message_subject: welcome_message_subject,
      welcome_message_body: welcome_message_body,
      description: description,
      created_at: created_at.strftime("%FT%T")
    }.merge!(id_hash)
  end

  def index_on_common
    common_wrapper.index_reward(self) if common_wrapper
  end

  private

  def pluck_from_database(attribute)
    Reward.where(id: id).pluck("rewards.#{attribute}").first
  end
end
