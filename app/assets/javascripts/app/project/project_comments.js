App.views.Project.addChild('ProjectComments', {
  el: '#project_comments',

  activate: function(){
    this.parent.on('selectTab', this.render);
  },

  render: function(){
    if(this.$el.is(':visible')){
      this.$el.html('<div class="fb-comments" data-href=' + this.$(".project-fb-comment").attr("href") + ' data-num-posts=50 data-width="610"></div>');
      FB.XFBML.parse();
    }
  }
});
