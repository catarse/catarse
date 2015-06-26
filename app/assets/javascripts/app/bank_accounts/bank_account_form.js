App.addChild('BankAccountForm', _.extend({
  el: 'body[data-controller-name="bank_accounts"]',

  events: {
    'blur input' : 'checkInput',
  },

  activate: function(){
    this.setupForm();
  }

}, Skull.Form));

