class CreateSurveyAddressAnswer < ActiveRecord::Migration
  def change
    create_table :addresses do |t|
      t.references :country, null: false
      t.references :state
      t.text :address_street
      t.text :address_number
      t.text :address_complement
      t.text :address_neighbourhood
      t.text :address_city
      t.text :address_zip_code
      t.text :phone_number

      t.timestamps
    end

    create_table :survey_address_answers do |t|
      t.references :contribution, null: false
      t.references :address, null: false
    end
  end
end
