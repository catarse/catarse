class Address < ActiveRecord::Base
  include Shared::CommonWrapper

  REQUIRED_ATTRIBUTES = %i[
    address_city address_zip_code phone_number address_neighbourhood address_street address_number
  ].freeze

  belongs_to :country
  belongs_to :state

  after_save :index_on_common

  def common_index
    id_hash = common_id.present? ? {id: common_id} : {}

    {
      external_id: id,
      country_id: country.try(:common_id),
      state_id: state.try(:common_id),
      address_street: address_street,
      address_number: address_number,
      address_complement:	address_complement,
      address_neighbourhood: address_neighbourhood,
      address_city: address_city,
      address_zip_code: address_zip_code,
      phone_number: phone_number,
      address_state: address_state,
      created_at: created_at.try(:strftime, "%FT%T"),
      updated_at: updated_at.try(:strftime, "%FT%T")
    }.merge!(id_hash)
  end

  def index_on_common
    common_wrapper.index_address(self) if common_wrapper
  end

  def required_attributes
    return Address::REQUIRED_ATTRIBUTES unless international?

    Address::REQUIRED_ATTRIBUTES - %i[address_number address_neighbourhood phone_number]
  end

  def international?
    country.try(:name) != 'Brasil'
  end
end
