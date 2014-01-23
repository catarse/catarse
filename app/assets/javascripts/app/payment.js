App.addChild('Payment', _.extend({
  el: '#project_review #payment',

  events: {
    'click #payment_menu a' : 'onTabClick'
  },

  activate: function(){
    this.onTabClick({target: this.$('#payment_menu a:first')});
    this.on('selectTab', this.updatePaymentMethod);
  },

  updatePaymentMethod: function() {
    var $selected_tab = this.$('#payment_menu a.selected');
    $.post(this.$el.data('update-info-path'), {
      contribution: {
        payment_method: $selected_tab.prop('id')
      }
    })
  }

}, Skull.Tabs));

