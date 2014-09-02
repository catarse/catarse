App.addChild('Payment', _.extend({
  el: '#payment-engines',

  events: {
    'click .tab' : 'onTabClick'
  },

  activate: function(){
    _this = this;

    this.loadPaymentChoices();
    $('#live_in_brazil').on('change', function(){
      _this.loadPaymentChoices();
    });
  },

  updatePaymentMethod: function() {
    var $selected_tab = this.$('.tab.selected');
    $.ajax({
      url: this.$el.data('update-info-path'),
      type: 'PUT',
      data: { contribution: { payment_method: $selected_tab.prop('id') } }
    });
  },

  hideNationalPayment: function() {
    this.$('#MoIP').hide();
    this.$('.payments_type#MoIP_payment').hide();
  },

  selectInternationalPayment: function() {
    this.onTabClick({currentTarget: this.$('#PayPal')});
  },

  loadPaymentChoices: function() {
    if(!$('#live_in_brazil').prop('checked')) {
      this.hideNationalPayment();
      this.selectInternationalPayment();
    } else {
      this.$('#payment-engines #MoIP').show();
      this.onTabClick({currentTarget: this.$('.tabs:first')});
    }

    this.on('selectTab', this.updatePaymentMethod);
  }
}, Skull.Tabs));

