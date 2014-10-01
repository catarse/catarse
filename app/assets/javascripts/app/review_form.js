App.addChild('ReviewForm', _.extend({
  el: 'form#review_form',

  events: {
    'blur input' : 'checkInput',
    'change #contribution_country_id' : 'onCountryChange',
    'change #contribution_anonymous' : 'toggleAnonymousConfirmation',
    'click #next-step' : 'onNextStepClick'
  },

  onNextStepClick: function(){
    if(this.validate()){
      alert('valido');
    }
  },

  toggleAnonymousConfirmation: function(){
    this.$('#anonymous-confirmation').slideToggle('slow');
  },

  onCountryChange: function(){
    if(this.$country.val() == '36'){
      this.nationalAddress();
    }
    else{
      this.internationalAddress();
    }
  },

  internationalAddress: function(){
    this.$state.data('old_value', this.$state.val());
    this.$state.val('outro / other')
    this.$('[data-required-in-brazil]').prop('required', false);
  },

  nationalAddress: function(){
    this.$state.val(this.$state.data('old_value'))
    this.parent.payment.loadPaymentChoices();
    this.$('[data-required-in-brazil]').prop('required', 'required');
  },

  acceptTerms: function(){
    if(this.validate()){
      $('#payment').show();
      this.updateContribution();
    } else {
      return false;
    }
  },

  activate: function(){
    this.$country = this.$('#contribution_country_id');
    this.$country.val('36');
    this.$state = this.$('#contribution_address_state');
    this.parent.payment.loadPaymentChoices();
    this.setupForm();
    this.onCountryChange();
  },

  updateContribution: function(){
    var contribution_data = {
      payer_name: this.$('#contribution_full_name').val(),
      payer_email: this.$('#contribution_email').val(),
      address_street: this.$('#contribution_address_street').val(),
      address_number: this.$('#contribution_address_number').val(),
      address_complement: this.$('#contribution_address_complement').val(),
      address_neighbourhood: this.$('#contribution_address_neighbourhood').val(),
      address_zip_code: this.$('#contribution_address_zip_code').val(),
      address_city: this.$('#contribution_address_city').val(),
      address_state: this.$('#contribution_address_state').val(),
      address_phone_number: this.$('#contribution_phone_number').val()
    }
    $.post(this.$el.data('update-info-path'), {
      _method: 'put',
      contribution: contribution_data
    });
  }

}, Skull.Form));

