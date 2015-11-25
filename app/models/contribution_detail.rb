class ContributionDetail < ActiveRecord::Base
  include I18n::Alchemy
  TRANSITION_DATES = %i(refused_at paid_at pending_refund_at refunded_at)

  belongs_to :user
  belongs_to :project
  belongs_to :reward
  belongs_to :contribution
  belongs_to :payment

  delegate :available_rewards, :payer_email, :payer_name, to: :contribution
  delegate :pay, :refuse, :trash, :refund, :request_refund, :request_refund!,
           :credits?, :paid?, :refused?, :pending?, :deleted?, :refunded?, :direct_refund,
           :slip_payment?, :pending_refund?, :second_slip_path,
           :pagarme_delegator, :waiting_payment?, :slip_expired?, to: :payment

  scope :search_on_acquirer, ->(acquirer_name){ where(acquirer_name: acquirer_name) }
  scope :project_name_contains, ->(term) {
    joins(:project).where(project: Project.pg_search(term).reorder('').pluck(:id)) #we need reorder due to a bug in pg_search
  }
  scope :by_payment_id, ->(term) { where(%{translate(?, '".', '') IN (gateway_id, key, translate((gateway_data->'acquirer_tid')::text, '".', ''))}, term) }
  scope :by_user_id, ->(user_id) { where(user_id: user_id) }
  scope :by_gateway, ->(gateway) { where(gateway: gateway) }
  scope :by_payment_method, ->(payment_method) { where(payment_method: payment_method ) }
  scope :user_name_contains, ->(term) { joins(:user).where("unaccent(upper(users.name)) LIKE ('%'||unaccent(upper(?))||'%')", term) }
  scope :user_email_contains, ->(term) { joins(:user).where("unaccent(upper(users.email)) LIKE ('%'||unaccent(upper(?))||'%') OR unaccent(upper(payer_email)) LIKE ('%'||unaccent(upper(?))||'%')", term, term) }

  scope :with_state, ->(state){ where(state: state) }
  scope :was_confirmed, ->{ where("contribution_details.state = ANY(confirmed_states())") }

  # Scopes based on project state
  scope :with_project_state, ->(state){ where(project_state: state) }
  scope :for_successful_projects, -> { with_project_state('successful').available_to_display }
  scope :for_online_projects, -> {
    with_project_state(['online', 'waiting_funds']).
    where("contribution_details.state not in('deleted')")
  }
  scope :for_failed_projects, -> { with_project_state('failed').available_to_display }

  scope :available_to_display, -> {
    joins(:payment).
    where("contribution_details.state not in('deleted', 'refused', 'pending') OR payments.waiting_payment")
  }

  scope :slips_past_waiting, -> {
    where(payment_method: 'BoletoBancario',
          state: 'pending',
          waiting_payment: false,
          project_state: 'online')
  }

  scope :no_confirmed_contributions_on_project, -> {
    where("NOT EXISTS (
          SELECT true 
          FROM contributions c 
          WHERE 
            c.user_id = contribution_details.user_id 
            AND c.project_id = contribution_details.project_id 
            AND c.was_confirmed)"
         )
  }

  scope :pending, -> { joins(:payment).merge(Payment.waiting_payment) }

  scope :ordered, -> { order(id: :desc) }

  scope :total_confirmed_by_day, -> {
    was_confirmed.group("contribution_details.paid_at::date AT TIME ZONE '#{Time.zone.tzinfo.name}'").count
  }

  scope :total_confirmed_amount_by_day, -> {
    was_confirmed.group("contribution_details.paid_at::date AT TIME ZONE '#{Time.zone.tzinfo.name}'").sum(:value)
  }

  scope :total_by_address_state, -> {
    was_confirmed.joins(:user).group("upper(users.address_state)").count
  }

  def self.between_values(start_at, ends_at)
    return all unless start_at.present? && ends_at.present?
    where("value between ? and ?", start_at, ends_at)
  end

  def can_show_slip?
    self.slip_payment? && !self.slip_expired?
  end

  def can_generate_slip?
    self.slip_payment? &&
      self.project.online? &&
      self.pending? &&
      self.slip_expired? &&
      (self.reward.nil? || !self.reward.sold_out?)
  end

  def last_state_name
    if possible_states.empty?
      :pending
    else
      possible_states.
        sort! { |x,y| y[:at] <=> x[:at] }.
        first[:state_name]
    end
  end

  private
  def possible_states
    @possible_states ||= TRANSITION_DATES.map do |state_at|
      { state_name: state_at.to_s.gsub(/_at/, ''), at: self.send(state_at) }
    end.delete_if { |x| x[:at].nil? || x[:state_name] == self.state }
  end
end
