App.views.Contribution.addChild('ContributionForm', _.extend({
  el: 'form#contribution_form',

  clickReward: function(event){
    var option = this.$(event.currentTarget);
    this.selectReward(option);
    this.value.val(this.reward().minimum_value);
  },

  reward: function(){
    var $reward = this.$('input[type=radio]:checked');
    if($reward.length > 0){
      return _.find(this.rewards, function(r){ return r.id == $reward.val(); });
    }
  },

  selectReward: function(reward){
    this.choices.removeClass('selected');
    reward.prop('checked', true);
    reward.parents('.choice:first').addClass('selected');
  },

  resetReward: function(event){
    var reward = this.reward();
    if(reward){
      var value = this.value.val();
      if(!(/^(\d+)$/.test(value)) || (parseInt(value) < reward.minimum_value)){
        this.selectReward(this.$('#contribution_reward_id'));
      }
    }
  },

  activate: function(){
    this.value = this.$('#contribution_value');
    this.value.mask('000.000.000,00', {reverse: true});
    this.rewards = this.value.data('rewards');
    this.choices = this.$('li.choice');
    this.credits = this.$('#credits');
    this.selectReward(this.$('input[type=radio]:checked'));
    this.setupForm();
  }
}, Skull.Form));

