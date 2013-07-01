App.views.Project.addChild('ProjectBackers', _.extend({
  el: '#project_backers',

  activate: function(){
    this.$loader = this.$("#loading img");
    this.$loaderDiv = this.$("#loading");
    this.$results = this.$(".results");
    this.path = this.$el.data('path');
    this.filter = {};
    this.setupScroll();
  }

}, Skull.InfiniteScroll));

