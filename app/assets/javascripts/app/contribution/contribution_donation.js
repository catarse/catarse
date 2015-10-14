App.addChild('ContributionDonation', {
  el: '#contribution-donation',

  events: {
    'click .show-answer-faq' : 'toggleQuestion'
  },

  toggleQuestion: function(event){
    var $question = $(event.currentTarget).find('.box-slider');
    $question.toggleClass('closed');
    $question.toggleClass('u-margintop-20');
  },
});
