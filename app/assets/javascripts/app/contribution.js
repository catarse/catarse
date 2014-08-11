App.addChild('Contribution', {
  el: '#new-contribution',

  events: {
    'click label.back-reward-radio-reward' : 'clickReward'
  },

  activate: function(){
  },

  clickReward: function(event){
    this.$('label.back-reward-radio-reward').removeClass('selected');
    $(event.currentTarget).addClass('selected');
  }
});
