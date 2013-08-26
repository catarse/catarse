App.addChild('FeedbackSupport', {
  el: '#bootstrap-feedback',

  events: {
    'click .feedback-support.closed .toggle': 'openFeedbackSupport',
    'click .feedback-support.opened .toggle': 'closeFeedbackSupport',
  },

  activate: function() {
    this.$feedbackSupportClosed = this.$('.feedback-support.closed');
    this.$feedbackSupportOpened = this.$('.feedback-support.opened');
  },

  openFeedbackSupport: function() {
    this.$feedbackSupportClosed.fadeOut('fast');
    this.$feedbackSupportOpened.fadeIn('slow');
  },

  closeFeedbackSupport: function() {
    this.$feedbackSupportOpened.fadeOut('fast')
    this.$feedbackSupportClosed.fadeIn('slow');
  },
});
