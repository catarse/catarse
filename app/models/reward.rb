# coding: utf-8
class Reward < ActiveRecord::Base
  include RankedModel
  include ERB::Util

  before_destroy :check_if_is_destroyable

  belongs_to :project
  has_many :payments, through: :contributions
  has_many :contributions, dependent: :nullify

  ranks :row_order, with_same: :project_id

  validates_presence_of :minimum_value, :description, :deliver_at #, :days_to_delivery
  validates_numericality_of :minimum_value, greater_than_or_equal_to: 10.00, message: 'Valor deve ser maior ou igual a R$ 10'
  validates_numericality_of :maximum_contributions, only_integer: true, greater_than: 0, allow_nil: true
  validate :deliver_at_cannot_be_in_the_past
  scope :remaining, -> { where("
                               rewards.maximum_contributions IS NULL
                               OR (
                                rewards.maximum_contributions IS NOT NULL
                                AND (
                                      SELECT
                                      COUNT(distinct c.id)
                                      FROM
                                        contributions c JOIN payments p ON p.contribution_id = c.id
                                      WHERE
                                        p.state IN ('paid', 'pending')
                                        AND reward_id = rewards.id
                                    ) < maximum_contributions)") }
  scope :sort_asc, -> { order('id ASC') }

  delegate :display_deliver_estimate, :display_remaining, :name, :display_minimum, :short_description,
           :medium_description, :last_description, :display_description, to: :decorator

  before_save :log_changes
  after_save :expires_project_cache

  def deliver_at_cannot_be_in_the_past
    self.errors.add(:deliver_at, "Previsão de entrega deve ser superior a data em que o projeto entra no ar") if
      ( self.project.online_date && self.deliver_at < self.project.online_date.beginning_of_month ) || self.deliver_at < Time.current.beginning_of_month
  end

  def log_changes
    self.last_changes = self.changes.to_json
  end

  def to_s
    display_description
  end

  def decorator
    @decorator ||= RewardDecorator.new(self)
  end

  def sold_out?
    maximum_contributions && total_compromised >= maximum_contributions
  end

  def any_sold?
    total_compromised > 0
  end

  def total_contributions states = %w(paid pending)
    payments.with_states(states).count("DISTINCT contributions.id")
  end

  def total_compromised
    total_contributions %w(paid pending)
  end

  def remaining
    return nil unless maximum_contributions
    maximum_contributions - total_compromised
  end

  def check_if_is_destroyable
    if any_sold?
      project.errors.add 'reward.destroy', "can't destroy"
      return false
    end
  end

  def expires_project_cache
    project.expires_fragments 'project-rewards'
  end
end
