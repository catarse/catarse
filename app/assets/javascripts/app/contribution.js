App.addChild('Contribution', {
  el: '#new-contribution',

  events: {
    'click label.back-reward-radio-reward' : 'clickReward',
    'click button#submit' : 'submitForm',
    'blur #contribution_value' : 'resetReward'
  },

  submitForm: function(){
    this.$('form').submit();
    return false;
  },

  activate: function(){
    this.$('input[type=radio]:checked').parent().addClass('selected');
    this.$value = this.$('#contribution_value');
  },

  resetReward: function(event){
    if(parseInt('0' + this.$value.val()) < this.minimumValue()){
      this.$('label.back-reward-radio-reward:first').click();
    }
  },

  minimumValue: function(){
    return this.$('label.back-reward-radio-reward.selected').find('label[data-minimum-value]').data('minimum-value');
  },

  clickReward: function(event){
    $currentTarget = $(event.currentTarget);
    this.$('label.back-reward-radio-reward').removeClass('selected');
    $currentTarget.addClass('selected');
    this.$value.val(this.minimumValue());
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
