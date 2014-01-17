App.addChild('ChannelPostComments', _.extend({
  el: '#channel_posts_comments',

  activate: function(){
    this.render();
  },

  render: function() {
    if(this.$el.is(':visible')){
      this.$el.html('<div class="fb-comments" data-href=' + (window.location.host + '/' + window.location.pathname.split('/')[2]) + ' data-num-posts=50 data-width="768"></div>');
      FB.XFBML.parse();
    }
  }
}));

