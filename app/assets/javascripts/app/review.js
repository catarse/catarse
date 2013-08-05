App.addChild('Review', {
  el: '#main_content[data-action="create"][data-controller-name="backers"]',

  events: {
    'click #live_in_brazil' : 'toggleAddressFields'
  },

  toggleAddressFields: function(){
    this.$('fieldset.address_data').fadeToggle();
  },

  activate: function(){
  }
});

