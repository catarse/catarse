App.addChild('FeedbackSupport', {
  el: '#bootstrap-feedback',

  events: {
    'click .feedback-support[data-toggle="closed"]': 'openFeedbackSupport',
    'click .feedback-support[data-toggle="opened"] .toggle': 'closeFeedbackSupport',
  },

  activate: function() {
    this.$feedbackSupportClosed = this.$('.feedback-support[data-toggle="closed"]').addClass('closed');
    this.$feedbackSupportOpened = this.$('.feedback-support[data-toggle="opened"]');
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
