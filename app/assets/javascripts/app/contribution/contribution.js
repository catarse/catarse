App.addChild('Contribution', {
  el: '#new-contribution',

  events: {
    'click .radio label' : 'clickReward',
    'click #submit' : 'submitForm',
    'input #contribution_value' : 'restrictChars'
  },

  restrictChars: function(event){
    var $target = $(event.target);
    $target.val($target.val().replace(/[^\d,]/, ''));
  },

  submitForm: function(){
    this.$('form').submit();
    return false;
  },

  activate: function(){
    this.$value = this.$('#contribution_value');
    this.$minimum = this.$('#minimum-value');
    this.clickReward({currentTarget: this.$('input[type=radio]:checked').parent()[0]});
  },

  resetReward: function(event){
    if(parseInt('0' + this.$value.val()) < this.minimumValue()){
      this.selectReward(this.$('.radio label'));
    }
  },

  minimumValue: function(){
    return this.$('.selected').find('label[data-minimum-value]').data('minimum-value');
  },

  resetSelected: function(){
    this.$('.w-radio').removeClass('selected');
  },

  selectReward: function(reward){
    this.resetSelected();
    reward.find('input[type=radio]').prop('checked', true);
    reward.parent().addClass('selected');
  },

  clickReward: function(event){
    this.selectReward($(event.currentTarget));
    var minimum = this.minimumValue();
    this.$value.val(minimum);
    this.$minimum.html(minimum);
  }
});

App.addChild('FaqBox', {
  el: '#faq-box',

  events: {
    'click li.list-question' : 'clickQuestion'
  },

  clickQuestion: function(event){
    var $question = $(event.currentTarget);
    var $answer = $question.next();
    $question.toggleClass('open').toggleClass('alt-link');
    $answer.slideToggle('slow');
  },

  activate: function(){
    this.$('li.list-answer').hide();
  }
});
