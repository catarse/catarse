App.views.Project.addChild('Updates', _.extend({
  el: '#project_updates',

  activate: function(){
    this.$loader = this.$("#updates-loading img");
    this.$loaderDiv = this.$("#updates-loading");
    this.$results = this.$(".results");
    this.path = this.$el.data('path');
    this.filter = {};
    this.setupScroll();
  }

}, Skull.InfiniteScroll));


