App.views.Project.addChild('ProjectBackers', _.extend({
  el: '#project_backers',

  activate: function(){
    this.$loader = this.$("#backers-loading img");
    this.$loaderDiv = this.$("#backers-loading");
    this.$results = this.$(".results");
    this.path = this.$el.data('path');
    this.filter = {};
    this.setupScroll();
    this.parent.on('selectTab', this.fetchPage);
  }

}, Skull.InfiniteScroll));

