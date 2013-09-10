App.views.Project.addChild('ProjectBackers', _.extend({
  el: '#project_backers',

  activate: function(){
    this.$loader = this.$("#backers-loading img");
    this.$loaderDiv = this.$("#backers-loading");
    this.$results = this.$(".results");
    this.path = this.$el.data('path');
    this.filter = {available_to_count: true};
    this.setupScroll();
    this.parent.on('selectTab', this.fetchPage);
  },

  events:{
    "click input[type='radio'][name=backer_state]": "showBackers"
  },

  showBackers: function(){
    var state = $('input:radio[name=backer_state]:checked').val();
    this.filter = {};
    this.filter[state] = true;
    this.firstPage();
    this.fetchPage();
  }

}, Skull.InfiniteScroll));

