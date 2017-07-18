class MigrateUserAddresses < ActiveRecord::Migration
  def up
    states = State.all
    User.find_each.with_index do |user, index|
      puts index if index % 1000 == 0
      if user.address_street
        state_id = states.where(acronym: user.address_state).first.try(:id)
        country_id = user.country_id || 36
        user.create_address(country_id: country_id, address_street: user.address_street, address_number: user.address_number, address_complement: user.address_complement, address_neighbourhood: user.address_neighbourhood, address_city: user.address_city, address_zip_code: user.address_zip_code, phone_number: user.phone_number, address_state: user.address_state, state_id: state_id) rescue nil
        user.save!(validate: false) rescue nil
      end
    end
  end
end
