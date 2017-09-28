class RemoveAddressFields < ActiveRecord::Migration
  def change
    execute <<-SQL
      alter table contributions drop column address_city;
      alter table contributions drop column address_complement;
      alter table contributions drop column address_street;
      alter table contributions drop column address_number ;
      alter table contributions drop column address_state ;
      alter table contributions drop column address_phone_number ;
      alter table contributions drop column address_neighbourhood ;
      alter table contributions drop column address_zip_code ;
      alter table contributions drop column country_id ;

      alter table users drop column address_city;
      alter table users drop column address_street;
      alter table users drop column address_complement;
      alter table users drop column address_number ;
      alter table users drop column address_state ;
      alter table users drop column phone_number ;
      alter table users drop column address_neighbourhood ;
      alter table users drop column address_zip_code ;
      alter table users drop column country_id ;
      alter table users drop column address_country ;

    SQL
  end
end
