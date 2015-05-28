# coding: utf-8
class Contribution < ActiveRecord::Base
  has_notifications

  include I18n::Alchemy
  include PgSearch
  include Contribution::CustomValidators

  belongs_to :project
  belongs_to :reward
  belongs_to :user
  belongs_to :country
  has_many :payment_notifications
  has_many :payments
  has_many :details, class_name: 'ContributionDetail'

  validates_presence_of :project, :user, :value, :payer_email
  validates_numericality_of :value, greater_than_or_equal_to: 10.00

  scope :by_id, ->(id) { where(id: id) }
  scope :anonymous, -> { where(anonymous: true) }
  scope :not_anonymous, -> { where(anonymous: false) }
  scope :confirmed_last_day, -> { where("EXISTS(SELECT true FROM payments p WHERE p.contribution_id = contributions.id AND p.state = 'paid' AND (current_timestamp - p.paid_at) < '1 day'::interval)") }
  scope :can_cancel, -> { where(can_cancel: true) }

  # Contributions already refunded or with requested_refund should appear so that the user can see their status on the refunds list
  scope :can_refund, ->{ where(can_refund: true) }

  scope :available_to_display, -> {
    where("EXISTS (SELECT true FROM payments p WHERE p.contribution_id = contributions.id AND p.state NOT IN ('deleted', 'refused'))")
  }

  scope :ordered, -> { order(id: :desc) }

  begin
    attr_protected :state, :user_id
  rescue Exception => e
    puts "problem while using attr_protected in Contribution model:\n '#{e.message}'"
  end

  def recommended_projects
    user.recommended_projects.where("projects.id <> ?", project.id).order("count DESC")
  end

  def change_reward! reward
    self.reward_id = reward
    self.save
  end

  def can_refund?
    confirmed? && project.failed?
  end

  def confirmed?
    @confirmed ||= Contribution.where(id: self.id).pluck('contributions.is_confirmed').first
  end

  def invalid_refund
    _user = User.find_by(email: CatarseSettings[:email_contact])
    notify(:invalid_refund, _user, self) if _user
  end

  def available_rewards
    project.rewards.where('minimum_value <= ?', self.value).order(:minimum_value)
  end

  def notify_to_contributor(template_name, options = {})
    notify_once(template_name, self.user, self, options)
  end

  def notify_to_backoffice(template_name, options = {})
    _user = User.find_by(email: CatarseSettings[:email_payments])
    notify_once(template_name, _user, self, options) if _user
  end

  def self.payment_method_names
    ['Pagarme', 'PayPal', 'MoIP']
  end

  def pending?
    payments.with_state('pending').exists?
  end

  # Used in payment engines
  def price_in_cents
    (self.value * 100).round
  end

  def update_current_billing_info
    self.country_id = user.country_id
    self.address_street = user.address_street
    self.address_number = user.address_number
    self.address_complement = user.address_complement
    self.address_neighbourhood = user.address_neighbourhood
    self.address_zip_code = user.address_zip_code
    self.address_city = user.address_city
    self.address_state = user.address_state
    self.address_phone_number = user.phone_number
    self.payer_document = user.cpf
    self.payer_name = user.name
    self.payer_email = user.email
  end

  def update_user_billing_info
    user.update_attributes({
      country_id: country_id.presence || user.country_id,
      address_street: address_street.presence || user.address_street,
      address_number: address_number.presence || user.address_number,
      address_complement: address_complement.presence || user.address_complement,
      address_neighbourhood: address_neighbourhood.presence || user.address_neighbourhood,
      address_zip_code: address_zip_code.presence|| user.address_zip_code,
      address_city: address_city.presence || user.address_city,
      address_state: address_state.presence || user.address_state,
      phone_number: address_phone_number.presence || user.phone_number,
      cpf: payer_document.presence || user.cpf,
      name: payer_name || user.name
    })
  end

end
