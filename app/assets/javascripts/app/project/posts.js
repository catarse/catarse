App.views.Project.addChild('Posts', _.extend({
  el: '#project_posts',

  events: {
    'ajax:success .results .project_posts' : 'onPostDestroy',
    'ajax:success form#new_project_post' : 'onPostCreate',
    'click #load-more' : 'loadMore'
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
 
    this.filter = {};
    this.setupPagination(
      this.$("#posts-loading img"),
      this.$('#load-more'),
      this.$(".posts"),
      this.$el.data('path')
    );
    this.parent.on('selectTab', this.fetchPage);
  },

  posts: function(){
    return this.$('.results .project_posts');
  },

  onPostDestroy: function(e){
    var $target = $(e.currentTarget);
    $target.remove();
    this.parent.$('a#posts_link .count').html(' (' + this.posts().length + ')');
  }

}, Skull.Pagination));