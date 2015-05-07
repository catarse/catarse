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
           :credits?, :paid?, :pending?, :deleted?,
           :slip_payment?, :pending_refund?, :second_slip_path,
           :pagarme_delegator, to: :payment

  scope :search_on_acquirer, ->(acquirer_name){ where(acquirer_name: acquirer_name) }
  scope :project_name_contains, ->(term) {
    joins(:project).where(project: Project.pg_search(term).reorder('').pluck(:id)) #we need reorder due to a bug in pg_search
  }
  scope :by_payment_id, ->(term) { where("? IN (gateway_id, key, (gateway_data->'acquirer_tid')::text)", term) }
  scope :by_user_id, ->(user_id) { where(user_id: user_id) }
  scope :by_gateway, ->(gateway) { where(gateway: gateway) }
  scope :by_payment_method, ->(payment_method) { where(payment_method: payment_method ) }
  scope :user_name_contains, ->(term) { joins(:user).where("unaccent(upper(users.name)) LIKE ('%'||unaccent(upper(?))||'%')", term) }
  scope :user_email_contains, ->(term) { joins(:user).where("unaccent(upper(users.email)) LIKE ('%'||unaccent(upper(?))||'%') OR unaccent(upper(payer_email)) LIKE ('%'||unaccent(upper(?))||'%')", term, term) }

  scope :with_state, ->(state){ where(state: state) }
  scope :pending, ->{ where(state: 'pending') }
  scope :was_confirmed, ->{ where("contribution_details.state = ANY(confirmed_states())") }

  # Scopes based on project state
  scope :with_project_state, ->(state){ joins(:project).merge(Project.with_state(state)) }
  scope :for_successful_projects, -> { with_project_state('successful').available_to_display }
  scope :for_online_projects, -> { with_project_state(['online', 'waiting_funds']).available_to_display }
  scope :for_failed_projects, -> { with_project_state('failed').available_to_display }

  scope :available_to_display, -> {
    where("contribution_details.state not in('deleted', 'refused')")
  }

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
