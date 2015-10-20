App.addChild('BankAccountForm', _.extend({
  el: '.refund_bank_account_form',

  events: {
    'blur input' : 'checkInput',
    'blur select' : 'checkInput',
    'change select#bank_account_bank_id': 'showBankNumberForm',
    'click a#show_bank_list': 'toggleBankList',
    'click a.bank-resource-link': 'fillWithSelectedBank'
  },

  activate: function(){
    this.setupForm();
    this.$('.field_with_errors .text-error').slideDown('slow');
    this.$('#bank_account_owner_name').data('custom-validation', this.validateName);
    this.$('#bank_account_agency').data('custom-validation', this.padZeros);
    this.$('#bank_account_input_bank_number').data('custom-validation', this.validateBankNumber);
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

  fillWithSelectedBank: function(event) {
    $target = this.$(event.currentTarget);

    this.$('input#bank_account_input_bank_number').val($target.data('code'));
    this.$('select#bank_account_bank_id').val($target.data('id'));
    this.$('input#bank_account_input_bank_number').trigger('blur');
    this.toggleBankList();
  },

  validateBankNumber: function(field) {
    var that = this

    if(field.val().length != 3){
      $(field).trigger('invalid');
      return false;
    }

    return true;
  },

  padZeros: function(field) {
    field.val(("0000" + field.val()).substr(-4,4));

    return true;
  },

  validateName: function(field) {
    if(field.val().length < 5 || field.val().length > 30){
      $(field).trigger('invalid');
      return false;
    }

    return true;
  },

}, Skull.Form));

