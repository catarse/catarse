# coding: utf-8
# frozen_string_literal: true

class Contribution < ActiveRecord::Base
  has_notifications

  include I18n::Alchemy
  include PgSearch
  include Contribution::CustomValidators

  belongs_to :project
  belongs_to :reward
  belongs_to :shipping_fee
  belongs_to :user
  belongs_to :address
  belongs_to :address_answer, class_name: 'Address'
  belongs_to :donation
  belongs_to :origin
  has_many :payment_notifications
  has_many :payments
  has_many :details, class_name: 'ContributionDetail'
  has_many :balance_transactions
  accepts_nested_attributes_for :address, allow_destroy: true, limit: 1 #payment address
  accepts_nested_attributes_for :address_answer, allow_destroy: true #survey answer addresses

  validates_presence_of :project, :user, :value
  validates_numericality_of :value, greater_than_or_equal_to: 10.00

  scope :not_anonymous, -> { where(anonymous: false) }
  scope :confirmed_last_day, -> { where("EXISTS(SELECT true FROM payments p WHERE p.contribution_id = contributions.id AND p.state = 'paid' AND (current_timestamp - p.paid_at) < '1 day'::interval)") }
  scope :was_confirmed, -> { where('contributions.was_confirmed') }

  scope :available_to_display, -> {
    where("EXISTS (SELECT true FROM payments p WHERE p.contribution_id = contributions.id AND p.state NOT IN ('deleted', 'refused'))")
  }

  scope :ordered, -> { order(id: :desc) }
  delegate :address_city, :country_id, :state_id, :state, :phone_number, :country, :state, :address_complement, :address_neighbourhood, :address_zip_code, :address_street, :address_number, :address_state, to: :address, allow_nil: true

  begin
    attr_protected :state, :user_id
  rescue Exception => e
    puts "problem while using attr_protected in Contribution model:\n '#{e.message}'"
  end

  # contributions that have not confirmed delivery after 14 days
  def self.need_notify_about_delivery_confirmation
    where("reward_received_at IS NULL AND reward_sent_at < current_timestamp - '14 days'::interval")
  end

  # Return contributions that need notify pending refunds without bank accounts registered
  def self.need_notify_about_pending_refund
    joins("
      join contribution_details cd on cd.contribution_id = contributions.id
      ").where("
      cd.project_state = 'failed'
      and contributions.donation_id is null
      and cd.state = 'paid'
      and lower(cd.gateway) = 'pagarme'
      and lower(cd.payment_method) = 'boletobancario'
      and (exists(select true from contribution_notifications un where un.contribution_id = contributions.id
      and un.template_name = 'contribution_project_unsuccessful_slip_no_account'
      and (current_timestamp - un.created_at) > '7 days'::interval) or not exists(select true from contribution_notifications un where un.contribution_id = contributions.id and un.template_name = 'contribution_project_unsuccessful_slip_no_account'))").uniq
  end

  def recommended_projects
    user.recommended_projects.where('projects.id <> ?', project.id).order('count DESC')
  end

  def international?
    (country || user.country).try(:name) != 'Brasil'
  end

  def change_reward!(reward)
    self.reward_id = reward
    save
  end

  def confirmed?
    @confirmed ||= Contribution.where(id: id).pluck('contributions.is_confirmed').first
  end

  def over_refund_limit?
    notifications.where(template_name: 'invalid_refund').count > 2
  end

  def was_confirmed?
    @was_confirmed ||= Contribution.where(id: id).pluck('contributions.was_confirmed').first
  end

  def slip_payment?
    payments.last.slip_payment?
  end

  def is_donation?
    donation.present?
  end

  def invalid_refund
    notify(:invalid_refund, user)
    if over_refund_limit?
      backoffice_user = User.find_by(email: CatarseSettings[:email_contact])
      notify_to_backoffice(:over_refund_limit, { from_email: user.email }, backoffice_user)
    end
  end

  def notify_to_contributor(template_name, options = {})
    notify_once(template_name, user, self, options)
  end

  def notify_to_backoffice(template_name, options = {}, backoffice_user = User.find_by(email: CatarseSettings[:email_payments]))
    notify_once(template_name, backoffice_user, self, options) if backoffice_user
  end

  def pending?
    payments.with_state('pending').exists?
  end
  def balance_refunded?
    balance_transactions.where(event_name: 'contribution_refund').exists?
  end

  # Used in payment engines
  def price_in_cents
    (value * 100).round
  end

  def update_current_billing_info
    self.payer_document = user.cpf
    self.payer_name = user.name
    self.payer_email = user.email
  end

  def update_user_billing_info
    user.update_attributes({
                             account_type: (user.cpf.present? ? user.account_type : ((payer_document.try(:size) || 0) > 14 ? 'pj' : 'pf')),
                             cpf: user.cpf.presence || payer_document.presence,
                             name: user.name.presence || payer_name,
                             public_name: user.public_name.presence || user.name.presence || payer_name
                           })
    address_attributes = {
                             country_id: country_id.presence || user.country_id,
                             state_id: state_id.presence || user.state_id,
                             address_street: address_street.presence || user.address_street,
                             address_number: address_number.presence || user.address_number,
                             address_complement: address_complement.presence || user.address_complement,
                             address_neighbourhood: address_neighbourhood.presence || user.address_neighbourhood,
                             address_zip_code: address_zip_code.presence || user.address_zip_code,
                             address_city: address_city.presence || user.address_city,
                             address_state: address_state.presence || user.state.try(:acronym) || user.address_state,
                             phone_number: phone_number.presence || user.phone_number,
                         }
    if user.address
      user.address.update_attributes(address_attributes)
    else
      user.create_address(address_attributes)
      user.save
    end
  end

  def to_js
    {
      id: id,
      value: value,
      reward: {
        id: reward ? reward.id : nil,
        description: reward ? reward.description : nil,
        title: reward ? reward.title : nil,
        shipping_options: reward ? reward.shipping_options : nil
      },
      shipping_fee_id: shipping_fee_id ? shipping_fee_id : nil
    }
  end

  def to_json
    to_js.to_json
  end

  def contribution_attributes
    payment = payments.last
    {
      contribution_id: id,
      value: value,
      project: {
        category: project.category.name_pt,
        user_thumb: project.user.decorate.display_image,
        permalink: project.permalink,
        total_contributions: project.total_contributions,
        service_fee: project.service_fee,
        name: project.name
      },
      reward: reward ? {
        reward_id:  reward.id,
        minimum_value: reward.minimum_value
      } : nil,
      contribution_email: user.email,
      slip_url: payment && payment.slip_payment? ? payment.gateway_data['boleto_url'] : nil
    }
  end

  def contribution_json
    contribution_attributes.to_json
  end
end
