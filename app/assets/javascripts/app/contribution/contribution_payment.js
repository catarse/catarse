App.addChild('Payment', {
  el: '#payment-engines',

  events: {
    'change #payment_card_number' : 'payment_card_number_change'
  },

  payment_card_number_change: function(event) {
    CatarseAnalytics.oneTimeEvent({cat:'contribution_finish',act:'contribution_cc_edit'});
  },

  activate: function(){
    var that = this;
    $.get(this.$("#engine").data('path')).success(function(data){
      that.$("#engine").html(data);
    });
  },

  show: function(){
    this.$el.slideDown('slow');
  }

});
