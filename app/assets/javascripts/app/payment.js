App.addChild('Payment', _.extend({
  el: '#main_content[data-action="create"][data-controller-name="backers"] #payment',

  events: {
    'click #payment_menu a' : 'onTabClick'
  },

  activate: function(){
    this.onTabClick({target: this.$('#payment_menu a:first')});
  }

}, Skull.Tabs));

