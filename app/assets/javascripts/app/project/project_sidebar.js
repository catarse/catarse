App.addChild('ProjectSidebar', {
  el: '#project-sidebar',

  events:{
    "click .card-reward" : "selectReward"
  },

  selectReward: function(event){
    var url = this.$(event.currentTarget).data('new_contribution_url');
    this.navigate(url);
    return false;
  },

  activate: function() {
    this.$rewards = this.$('#rewards');
    this.reloadRewards();
  },

  reloadRewards: function() {
    var that = this;
    $.get(that.$rewards.data('index_path')).success(function(data){
      that.$rewards.html(data);
    });
  }

});

