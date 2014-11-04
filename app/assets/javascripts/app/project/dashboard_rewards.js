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
  },

  toggleExplanation: function() {
    event.preventDefault();
    this.$('.reward-explanation').toggle();
  },

  closeForm: function() {
    event.preventDefault();
    this.$('.reward-explanation').toggle();
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


  showRewardForm: function(event) {
    event.preventDefault();
    var $target = this.$(event.currentTarget);
    $target.fadeOut('fast');

    $.get($target.data('path')).success(function(data){
      $($target.data('target')).html(data);
    });

    this.$($target.data('target')).fadeIn('fast');
  }
});

