App.views.User.addChild('UserContributions', _.extend({
  el: '#user_contributed_projects',

  activate: function(){
    this.$loader = this.$(".loading img");
    this.$loaderDiv = this.$(".loading");
    this.$results = this.$(".results");
    this.path = this.$el.data('path');
    this.filter = {};
    this.setupScroll();
    this.fetchPage();
  }

}, Skull.InfiniteScroll));

