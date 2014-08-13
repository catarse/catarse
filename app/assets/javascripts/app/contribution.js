App.addChild('Contribution', {
  el: '#new-contribution',

  events: {
    'click label.back-reward-radio-reward' : 'clickReward',
    'click a#submit' : 'submitForm'
  },

  submitForm: function(){
    this.$('form').submit();
    return false;
  },

  activate: function(){
    this.$('input[type=radio]:checked').parent().addClass('selected');
  },

  clickReward: function(event){
    this.$('label.back-reward-radio-reward').removeClass('selected');
    $(event.currentTarget).addClass('selected');
  }
});

App.views.Contribution.addChild('FaqBox', {
  el: '#faq-box',

  events: {
    'click li.faq-box-question' : 'clickQuestion'
  },

  clickQuestion: function(event){
    var $question = $(event.currentTarget);
    var $answer = $question.next();
    $question.toggleClass('open').toggleClass('alt-link');
    $answer.slideToggle('slow');
  },

  activate: function(){
    this.$('li.faq-box-answer').hide();
  }
});
