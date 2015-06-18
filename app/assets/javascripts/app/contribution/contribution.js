App.addChild('Contribution', {
  el: '#new-contribution',

  events: {
    'click .radio label' : 'clickReward',
    'click .submit-form' : 'submitForm',
    'input #contribution_value' : 'restrictChars'
  },

  restrictChars: function(event){
    var $target = $(event.target);
    $target.val($target.val().replace(/[^\d,]/, ''));
  },

  submitForm: function(){
    var user_value = this.$('.selected').find('.user-reward-value').val();
    var default_value = this.$('.selected').find('label[data-minimum-value]').data('minimum-value');
    this.$value.val(user_value || default_value);
    this.$('form').submit();
    return false;
  },

  activate: function(){
    this.$('.user-reward-value').mask('000.000.000,00', {reverse: true});
    this.$value = this.$('#contribution_value');
    this.$minimum = this.$('#minimum-value');
    this.clickReward({currentTarget: this.$('input[type=radio]:checked').parent()[0]});
    this.activateFloattingHeader();
  },

  activateFloattingHeader: function(){
    var top;
    var top_title = $('#new-contribution'),
    faq_top = $("#faq-box").offset().top;
    $(window).scroll(function() {
        top = $(top_title).offset().top, 
        $(window).scrollTop() > top ? $(".reward-floating").addClass("reward-floating-display") : $(".reward-floating").removeClass("reward-floating-display");
        var t = $("#faq-box");
        $(window).scrollTop() > faq_top ? $(t).hasClass("faq-card-fixed") || $(t).addClass("faq-card-fixed") : $(t).hasClass("faq-card-fixed") && $(t).removeClass("faq-card-fixed")
    });
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
    this.$('.back-reward-money').hide();
    reward.find('.back-reward-money').show();
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
