App.addChild('Contribution', {
  el: '#new-contribution',

  events: {
    'click label.back-reward-radio-reward' : 'clickReward'
  },

  activate: function(){
    this.$('input[type=radio]:checked').parent().addClass('selected');
  },

  clickReward: function(event){
    this.$('label.back-reward-radio-reward').removeClass('selected');
    $(event.currentTarget).addClass('selected');
  }
});
