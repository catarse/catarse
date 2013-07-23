App.views.Project.addChild('ProjectSidebar', {
  el: '.sidebar',

  events:{
    "click .show_reward_form": "showRewardForm"
  },

  showRewardForm: function(event) {
    event.preventDefault();
    var $target = this.$(event.currentTarget);
    $target.fadeOut('fast');
    this.$($target.data('target')).fadeIn('fast');
  }
});

