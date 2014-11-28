App.addChild('DashboardRewards', {
  el: '#dashboard-rewards-tab',

  events:{
    "click .show_reward_form": "showRewardForm",
    "click .reward-close-button": "closeForm",
    "click .fa-question-circle": "toggleExplanation"
  },

  activate: function() {
    this.$rewards = this.$('#dashboard-rewards');
    this.sortableRewards();
    this.showNewRewardForm();
  },

  toggleExplanation: function() {
    event.preventDefault();
    this.$('.reward-explanation').toggle();
  },

  closeForm: function(event) {
    event.preventDefault();
    var $target = this.$(event.currentTarget);
    $target.closest('.reward-card').hide();
    $target.closest('.reward-card').parent().prev().show();
  },

  sortableRewards: function() {
    this.$rewards.sortable({
      axis: 'y',
      placeholder: "ui-state-highlight",
      start: function(e, ui) {
        return ui.placeholder.height(ui.item.height());
      },
      update: function(e, ui) {
        var csrfToken, position;
        position = $('#dashboard-rewards .sortable').index(ui.item);
        csrfToken = $("meta[name='csrf-token']").attr("content");
        return $.ajax({
          type: 'POST',
          url: ui.item.data('update_url'),
          dataType: 'json',
          headers: {
            'X-CSRF-Token': csrfToken
          },
          data: {
            reward: {
              row_order_position: position
            }
          }
        });
      }
    })
  },

  showNewRewardForm: function(event) {
    var that = this;
    var $target = this.$('.new_reward_button');
    if(this.$('.sortable').length == 0)
    {
      $.get($target.data('path')).success(function(data){
        $($target.data('target')).html(data);
        that.rewardForm;
      });

      this.$($target.data('target')).fadeIn('fast');
    }

  },

  showRewardForm: function(event) {
    var that = this;
    event.preventDefault();
    var $target = this.$(event.currentTarget);

    $.get($target.data('path')).success(function(data){
      $($target.data('target')).html(data);
      that.rewardForm;
    });

    this.$($target.data('parent')).hide();
    this.$($target.data('target')).fadeIn('fast');

  }
});

App.views.DashboardRewards.addChild('RewardForm', _.extend({
  el: '.reward-card',

  events: {
    'ajax:complete' : 'onComplete',
    'blur input' : 'checkInput',
    'submit form' : 'validate'
  },

  onComplete: function(event, data){
    console.log(data);
    if(data.status === 302){
      window.location.reload();
    }
    else{
      var form = $(data.responseText).html();
      this.$el.html(form)
    }
  },

  activate: function(){
    this.setupForm();
  }
}, Skull.Form));
