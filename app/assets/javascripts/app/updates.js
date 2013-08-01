App.views.Project.addChild('Updates', _.extend({
  el: '#project_updates',

  events: {
    'ajax:success .results .update' : 'onUpdateDestroy',
    'ajax:success form#new_update' : 'onUpdateCreate'
  },

  onUpdateCreate: function(e, data){
    this.$results.prepend(data);
  },

  activate: function(){
    this.$loader = this.$("#updates-loading img");
    this.$loaderDiv = this.$("#updates-loading");
    this.$results = this.$(".results");
    this.path = this.$el.data('path');
    this.filter = {};
    this.setupScroll();
    this.parent.on('selectTab', this.fetchPage);
    this.on('scroll:success', this.parseXFBML);
  },

  parseXFBML: function(){
    if(this.$el.is(':visible')){
      FB.XFBML.parse();
    }
  },

  updates: function(){
    return this.$('.results .update');
  },

  onUpdateDestroy: function(e){
    var $target = $(e.currentTarget);
    $target.remove();
    this.parent.$('a#updates_link .count').html(' (' + this.updates().length + ')');
  }

}, Skull.InfiniteScroll));


