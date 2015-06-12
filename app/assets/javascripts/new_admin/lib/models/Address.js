var Address = function(data){
  data = data || {};
  this.country_id = m.prop(data.country_id);
  this.address_number = m.prop(data.address_number);
  this.address_street = m.prop(data.address_street);
  this.address_complement = m.prop(data.address_complement);
  this.address_neighbourhood = m.prop(data.address_neighbourhood);
  this.address_zip_code = m.prop(data.address_zip_code);
  this.address_city = m.prop(data.address_city);
  this.address_state = m.prop(data.address_state);
  this.phone_number = m.prop(data.phone_number);
};

admin_app.Address = Address;