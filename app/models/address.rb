class Address < ActiveRecord::Base
  include Shared::CommonWrapper

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
end
