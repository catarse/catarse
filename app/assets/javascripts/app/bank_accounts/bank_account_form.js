App.addChild('BankAccountForm', _.extend({
  el: '.refund_bank_account_form',

  events: {
    'blur input' : 'checkInput',
  },

  activate: function(){
    this.setupForm();
  }

}, Skull.Form));

