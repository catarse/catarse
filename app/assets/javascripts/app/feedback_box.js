App.addChild('FeedbackBox', {
  el: '.feedback-box',

  events: {
    "click a.close-button" : "closeBox",
  },

  activate: function(){

  },

  closeBox: function() {
    this.$el.addClass('feedback-box-closed');
    return false;
  },
});