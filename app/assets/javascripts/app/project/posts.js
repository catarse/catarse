App.views.Project.addChild('Posts', _.extend({
  el: '#project_posts',

  events: {
    'ajax:success .results .post' : 'onPostDestroy',
    'ajax:success form#new_project_post' : 'onPostCreate'
  },

  onPostCreate: function(e, data){
    $('#post_submit').attr('disabled','disabled');
    $('.ghost-flash').addClass('flash').removeClass('hide', 'ghost-flash');
    app.flash();
    this.$results.prepend(data);
    $("input[type=text], textarea").val("");
    $('#post_submit').removeAttr('disabled');
  },

  activate: function(){
    this.$loader = this.$("#posts-loading img");
    this.$loaderDiv = this.$("#posts-loading");
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

  posts: function(){
    return this.$('.results .post');
  },

  onPostDestroy: function(e){
    var $target = $(e.currentTarget);
    $target.remove();
    this.parent.$('a#posts_link .count').html(' (' + this.posts().length + ')');
  }

}, Skull.InfiniteScroll));


