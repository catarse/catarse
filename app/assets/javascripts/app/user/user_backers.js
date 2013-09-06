App.views.User.addChild('UserBackers', _.extend({
  el: '#user_backed_projects',

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

