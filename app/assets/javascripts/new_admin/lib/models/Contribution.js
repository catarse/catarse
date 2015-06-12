//Contribution.model.js
var Contribution = function(data){
  data = data || {};  
  this.id = m.prop(data.id);
  this.user_id = m.prop(data.user_id);
  this.project_id = m.prop(data.project_id);
  this.reward_id = m.prop(data.reward_id);
  this.contribution_value = m.prop(data.contribution_value);
  this.anonymous = m.prop(data.anonymous);
  this.notified_finish = m.prop(data.notified_finish);
  this.payer_name = m.prop(data.payer_name);
  this.payer_email = m.prop(data.payer_email);
  this.payer_document = m.prop(data.payer_document);
  this.payment_choice = m.prop(data.payment_choice);
  this.payment_service_fee = m.prop(data.payment_service_fee);
  this.referral_link = m.prop(data.referral_link);
  this.address = m.prop(data.address);
  this.created_at = m.prop(data.created_at);
  this.updated_at = m.prop(data.updated_at);
  this.deleted_at = m.prop(data.deleted_at);
}

Contribution.get = function(filter) {

  var data = [];
  //quick manual factory
  for(var i = 0; i < 5; i++){
    data[i] = {
      id : i,
      user_id : i,
      project_id : i,
      reward_id : i,
      contribution_value : i*100,
      anonymous : i%2,
      notified_finish : false,
      payer_name : 'payer_'+i,
      payer_email : 'payer_'+i+'@payer.com',
      payer_document : 'cpfdopayer',
      payment_choice : 'slip',
      payment_service_fee : 0,
      referral_link: 'hello',
      address : new admin_app.Address(),
      created_at : Date.now(),
      updated_at : Date.now(),
    };
  }
  return data;
  //return m.postgrest.request({method: "GET", url: "/contribution", data: filter});
}

admin_app.Contribution = Contribution;