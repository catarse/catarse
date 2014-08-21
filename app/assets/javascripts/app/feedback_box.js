App.addChild('FeedbackBox', {
  el: '.feedback-box',

  events: {
    "click a.close-button" : "closeBox",
    "ajax:success" : "onSuccess",
    "blur #user_email" : "onBlurEmail"
  },

  onBlurEmail: function(){
    this.$('#user_name').val(this.$('#user_email').val());
  },

  onSuccess: function(){
    this.$('.w-form').hide();
    this.$('#title').hide();
    this.$('#description').hide();
    this.$('#thanks-title').fadeIn('slow');
    this.$('#thanks-description').fadeIn('slow');
  },

  activate: function(){
    this.$('#thanks-title').hide();
    this.$('#thanks-description').hide();
    if(!store.get('feedbackFormClosed') && !$.isEmptyObject($("body").data("user"))){
      this.openBox();
    }
  },

  openBox: function(){
    store.set('feedbackFormClosed', false);
    this.$el.removeClass("feedback-box-closed");
    return false;
  },

  closeBox: function() {
    store.set('feedbackFormClosed', true);
    this.$el.addClass('feedback-box-closed');
    return false;
  },
});
