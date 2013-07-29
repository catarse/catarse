App.views.User.addChild('UserProjects', _.extend({
  el: '#user_created_projects',

  activate: function(){
    this.$loader = this.$(".loading img");
    this.$loaderDiv = this.$(".loading");
    this.$results = this.$(".results");
    this.path = this.$el.data('path');
    this.filter = {};
    this.setupScroll();
  }

}, Skull.InfiniteScroll));

