class ContributionDetail < ActiveRecord::Base
  belongs_to :user
  belongs_to :project
  belongs_to :reward
  belongs_to :contribution
  belongs_to :payment

  delegate :available_rewards, :payer_email, :payer_name, to: :contribution
  delegate :pay, :refuse, :trash, :refund, :request_refund, 
           :credits?, :paid?, :pending?, :deleted?, 
           :slip_payment?, :pending_refund?, :second_slip_path, to: :payment

  scope :search_on_acquirer, ->(acquirer_name){ where(acquirer_name: acquirer_name) }
  scope :project_name_contains, ->(term) {
    joins(:project).merge(Project.pg_search(term))
  }
  scope :by_payment_id, ->(term) { where("? IN (payment_id, key, acquirer_tid)", term) }
  scope :by_user_id, ->(user_id) { where(user_id: user_id) }
  scope :by_gateway, ->(gateway) { where(gateway: gateway) }
  scope :by_payment_method, ->(payment_method) { where(payment_method: payment_method ) }
  scope :user_name_contains, ->(term) { joins(:user).where("unaccent(upper(users.name)) LIKE ('%'||unaccent(upper(?))||'%')", term) }
  scope :user_email_contains, ->(term) { joins(:user).where("unaccent(upper(users.email)) LIKE ('%'||unaccent(upper(?))||'%') OR unaccent(upper(payer_email)) LIKE ('%'||unaccent(upper(?))||'%')", term, term) }

  def self.between_values(start_at, ends_at)
    return all unless start_at.present? && ends_at.present?
    where("value between ? and ?", start_at, ends_at)
  end

end
