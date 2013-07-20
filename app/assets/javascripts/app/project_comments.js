App.views.Project.addChild('ProjectComments', {
  el: '#project_comments',

  activate: function(){
    this.parent.on('onSelectTab', this.render);
  },

  render: function(){
    this.$el.html('<div class="fb-comments" data-href=' + window.location.href + ' data-num-posts=50 data-width="610"></div>');
    FB.XFBML.parse();
  }
});
