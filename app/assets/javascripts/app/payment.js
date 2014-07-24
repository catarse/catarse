App.addChild('Payment', _.extend({
  el: '#project_review #payment',

  events: {
    'click #payment_menu a' : 'onTabClick'
  },

  activate: function(){
    _this = this;

    this.loadPaymentChoices();

    $('#live_in_brazil').on('change', function(){
      _this.loadPaymentChoices();
    });
  },

  updatePaymentMethod: function() {
    var $selected_tab = this.$('#payment_menu a.selected');
    $.ajax({
      url: this.$el.data('update-info-path'),
      type: 'PUT',
      data: { contribution: { payment_method: $selected_tab.prop('id') } }
    });
  },

  hideNationalPayment: function() {
    this.$('#payment_menu a#MoIP').hide();
    this.$('.payments_type#MoIP_payment').hide();
  },

  selectInternationalPayment: function() {
    this.onTabClick({currentTarget: this.$('#payment_menu a#PayPal')});
  },

  loadPaymentChoices: function() {
    if(!$('#live_in_brazil').prop('checked')) {
      this.hideNationalPayment();
      this.selectInternationalPayment();
    } else {
      this.$('#payment_menu a#MoIP').show();
      this.onTabClick({currentTarget: this.$('#payment_menu a:first')});
    }

    this.on('selectTab', this.updatePaymentMethod);
  }
}, Skull.Tabs));

