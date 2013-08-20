App.addChild('ReviewForm', _.extend({
  el: 'form#review_form',

  events: {
    'blur input' : 'checkInput',
    'click #accept' : 'acceptTerms',
    'click #live_in_brazil' : 'toggleAddressFields'
  },

  toggleAddressFields: function(){
    this.$('fieldset.address_data').fadeToggle();
  },

  acceptTerms: function(){
    if(this.validate()){
      $('#payment').show();
      this.updateBacker();
    }
  },

  activate: function(){
    this.setupForm();
  },

  updateBacker: function(){
    var backer_data = {
      payer_name: this.$('#user_full_name').val(),
      payer_email: this.$('#user_email').val(),
      address_street: this.$('#user_address_street').val(),
      address_number: this.$('#user_address_number').val(),
      address_complement: this.$('#user_address_complement').val(),
      address_neighbourhood: this.$('#user_address_neighbourhood').val(),
      address_zip_code: this.$('#user_address_zip_code').val(),
      address_city: this.$('#user_address_city').val(),
      address_state: this.$('#user_address_state').val(),
      address_phone_number: this.$('#user_phone_number').val()
    }
    $.post(this.$el.data('update-info-path'), {
      backer: backer_data
    });
  }
}, Skull.Form));

