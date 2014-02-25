App.addChild('ChannelProfile', _.extend({
  el: '#channel-profile',

  events: {
    'click .video-thumb' : 'clickVideoThumb',
    'click .big-video-close' : 'clickBigVideoClose'
  },

  clickBigVideoClose: function(){
    var that = this;
    this.bigVideo.slideUp( "slow", function() {
      that.player.api('pause');
      that.bigVideoClose.toggle();
      that.channelBio.slideDown();
      $('html,body').animate({scrollTop: 0},'slow');
    });
  },

  clickVideoThumb: function(){
    var that = this;
    this.channelBio.toggle();
    this.bigVideo.slideDown( "slow", function() {
      $('html,body').animate({scrollTop: that.bigVideo.offset().top},'slow');
      that.player.api('play');
    });
    this.bigVideoClose.toggle("easein");
  },

  activate: function(){
    this.bigVideo = this.$('.big-video');
    this.bigVideoClose = this.$('.big-video-close');
    this.channelBio = this.$('.channel-bio');
    this.player = $f(this.$('iframe.load-video')[0]);
  }

}));


