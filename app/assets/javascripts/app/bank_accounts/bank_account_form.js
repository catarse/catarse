App.addChild('BankAccountForm', _.extend({
  el: '.refund_bank_account_form',

  events: {
    'blur input' : 'checkInput',
    'blur select' : 'checkInput',
  },

  activate: function(){
    this.setupForm();
    this.$('.field_with_errors .text-error').slideDown('slow');
    this.$('#bank_account_owner_name').data('custom-validation', this.validateName);
  },

  validateName: function(field) {
    if(field.val().length < 5 || field.val().length > 30){
      $(field).trigger('invalid');
      return false;
    }

    return true;
  },

}, Skull.Form));

