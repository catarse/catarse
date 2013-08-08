App.views.User.addChild('UserProjects', _.extend({
  el: '#user_created_projects',

  activate: function(){
    var that = this;
    this.$loader = this.$(".loading img");
    this.$loaderDiv = this.$(".loading");
    this.$results = this.$(".results");
    this.path = this.$el.data('path');
    this.filter = {};
    this.setupScroll();
    this.parent.on('selectTab', function(){
      if(that.$el.is(':visible')){
        that.fetchPage();
      }
    });
  }

}, Skull.InfiniteScroll));

