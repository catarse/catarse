App.addChild('BankAccountForm', _.extend({
  el: '.refund_bank_account_form',

  events: {
    'blur input' : 'checkInput',
    'blur select' : 'checkInput',
    'change select#bank_account_bank_id': 'showBankNumberForm',
    'click a#show_bank_list': 'toggleBankList'
  },

  activate: function(){
    this.setupForm();
    this.$('.field_with_errors .text-error').slideDown('slow');
    this.$('#bank_account_owner_name').data('custom-validation', this.validateName);
    //this.$('#bank_account_owner_name').data('custom-validation', this.validateName);
  },

  showBankNumberForm: function(event) {
    $target = this.$(event.currentTarget);
    $bank_select = this.$('#bank_select');
    $bank_search = this.$('#bank_search');

    if($target.val() == 0) {
      $bank_select.hide();
      $bank_search.show();
    }
  },

  toggleBankList: function(event) {
    $bank_list = this.$('#bank_search_list');
    $bank_list.slideToggle('slow');
  },

  validateName: function(field) {
    if(field.val().length < 5 || field.val().length > 30){
      $(field).trigger('invalid');
      return false;
    }

    return true;
  },

}, Skull.Form));

