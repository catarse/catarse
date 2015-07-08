App.addChild('Home', {
  el: '#hero-home',

  activate: function(){
    $.animateHeadline();
  },

});

App.addChild('HomeNewsletter', {
  el: '#mailee-form',

  events: {
	'click a.btn-attached':'submitForm',
  },

  submitForm: function(event){
	  event.preventDefault();
	  this.$el.submit();
  },

});