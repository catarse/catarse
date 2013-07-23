App.views.Project.addChild('ProjectSidebar', {
  el: '.sidebar',

  events:{
    "click .show_new_reward_form": "showNewRewardForm"
  },

  showNewRewardForm: function(event) {
    event.preventDefault();
    this.$(event.currentTarget).fadeOut('fast');
    this.$('.new_reward_content').fadeIn('fast');
  }
});

