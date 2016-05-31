App.addChild('ReviewForm', _.extend({
  el: 'form#review_form',

  events: {
    'blur input' : 'checkInput',
    'change #contribution_address_state' : 'checkInput',
    'change #contribution_country_id' : 'onCountryChange',
    'change #contribution_anonymous' : 'toggleAnonymousConfirmation',
    'click #next-step' : 'onNextStepClick',
    'change input': 'inputChange',
  },
  address_br: true,


  inputChange: function(event) {
    if(event.target.id!=='contribution_country_id' && event.target.id!=='contribution_anonymous') {
      CatarseAnalytics.oneTimeEvent({cat:'contribution_finish',act:this.address_br?'contribution_address_br':'contribution_address_int'});
    }
  },

  onNextStepClick: function(){
    if(this.validate()){
      this.updateContribution();
      this.$errorMessage.hide();
      this.$('#next-step').hide();
      this.$('input.error').removeClass('error');
      this.$('.text-error').hide();
      this.parent.payment.show();
      CatarseAnalytics.event({cat:'contribution_finish',act:'contribution_next_click'});
    }
    else{
      this.$errorMessage.slideDown('slow');
    }
  },

  toggleAnonymousConfirmation: function(){
    this.$('#anonymous-confirmation').slideToggle('slow');
    CatarseAnalytics.event({cat:'contribution_finish',act:'contribution_anonymous_change'});
  },

  onCountryChange: function(){
    this.address_br = (this.$country.val() == '36');
    if(this.address_br){
      this.nationalAddress();
    }
    else{
      this.internationalAddress();
    }
  },

  internationalAddress: function(){
    this.$state.data('old_value', this.$state.val());
    this.$state.val('outro / other');
    this.makeFieldsOptional();
  },

  makeFieldsRequired: function(){
    this.$('[data-required-in-brazil]').prop('required', 'required');
    this.$('[data-required-in-brazil]').parent().removeClass('optional').addClass('required');
    this.$('[data-required-in-brazil]').each(function() {
      if($(this).data('old-fixed-mask')) {
          $(this).data('fixed-mask', $(this).data('fixed-mask'));
          $(this).removeData('old-fixed-mask');
          $(this).fixedMask();
      }
    });
  },

  makeFieldsOptional: function(){
    this.$('[data-required-in-brazil]').prop('required', false);
    this.$('[data-required-in-brazil]').parent().removeClass('required').addClass('optional');
    this.$('[data-required-in-brazil]').each(function() {
      if($(this).data('fixed-mask')) {
          $(this).data('old-fixed-mask', $(this).data('fixed-mask'));
          $(this).removeData('fixed-mask');
          $(this).fixedMask('off');
      }
    });
  },

  nationalAddress: function(){
    if(this.$state.data('old_value')){
      this.$state.val(this.$state.data('old_value'));
    }
    this.makeFieldsRequired();
  },

  activate: function(){
    this.$country = this.$('#contribution_country_id');
    if(this.$country.val() === ''){
      this.$country.val('36');
    }
    this.$state = this.$('#contribution_address_state');
    this.$errorMessage = this.$('#error-message');
    this.setupForm();
    this.onCountryChange();

    this.$('input.required').prop('required', 'required');
    //CatarseAnalytics.event({cat:'contribution_finish',act:'contribution_started'});
  },

  updateContribution: function(){
    var contribution_data = {
      anonymous: this.$('#contribution_anonymous').is(':checked'),
      country_id: this.$('#contribution_country_id').val(),
      payer_name: this.$('#contribution_payer_name').val(),
      payer_email: this.$('#contribution_payer_email').val(),
      payer_document: this.$('#contribution_payer_document').val(),
      address_street: this.$('#contribution_address_street').val(),
      address_number: this.$('#contribution_address_number').val(),
      address_complement: this.$('#contribution_address_complement').val(),
      address_neighbourhood: this.$('#contribution_address_neighbourhood').val(),
      address_zip_code: this.$('#contribution_address_zip_code').val(),
      address_city: this.$('#contribution_address_city').val(),
      address_state: this.$('#contribution_address_state').val(),
      address_phone_number: this.$('#contribution_address_phone_number').val()
    };
    $.post(this.$el.data('update-info-path'), {
      _method: 'put',
      contribution: contribution_data
    });
  }

}, Skull.Form));
