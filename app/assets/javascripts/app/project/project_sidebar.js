App.views.Project.addChild('ProjectSidebar', {
  el: '.sidebar',

  events:{
    "click .show_reward_form": "showRewardForm",
    "click #rewards .box.clickable" : "selectReward"
  },

  selectReward: function(event){
    var url = this.$(event.currentTarget).data('new_contribution_url');
    this.navigate(url);
    return false;
  },

  activate: function() {
    this.$rewards = this.$('#rewards');
    this.sortableRewards();
    this.reloadRewards();
  },

  reloadRewards: function() {
    var that = this;
    $.get(that.$rewards.data('index_path')).success(function(data){
      that.$rewards.html(data);
    });
  },

  sortableRewards: function() {
    if(this.$rewards.data("can_update") == true){
      this.$rewards.sortable({
        axis: 'y',
        placeholder: "ui-state-highlight",
        start: function(e, ui) {
          return ui.placeholder.height(ui.item.height());
        },
        stop: function(e, ui) {
          return ui.item.effect('highlight', {}, 1000);
        },
        update: function(e, ui) {
          var csrfToken, position;
          position = $('#rewards .sortable').index(ui.item);
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
    }
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

