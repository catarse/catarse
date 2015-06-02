App.addChild('Payment', {
  el: '#payment-engines',

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

