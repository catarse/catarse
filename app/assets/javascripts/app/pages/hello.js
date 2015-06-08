App.addChild('Hello', {
  el: '[data-id="hello"]',

  events: {
    'click .btn-play'         : 'showVideo',
    'click .w-lightbox-close' : 'closeVideo'
  },

  activate: function(){
    var that = this;
    this.player = {};
    this.isLightboxOpened = false;
    this.loadIframeAPI();
    window.onYouTubePlayerAPIReady = this.createPlayer;
  },

  loadIframeAPI: function(){
    var tag = document.createElement('script');
    tag.src = "https://www.youtube.com/iframe_api";
    var firstScriptTag = document.getElementsByTagName('script')[0];
    firstScriptTag.parentNode.insertBefore(tag, firstScriptTag);
  },

  closeVideo: function(){
    if(!$.isEmptyObject(this.player) && typeof(this.player.pauseVideo) === 'function'){
      this.player.pauseVideo();
    }
    $('body').css('overflow','auto');
    this.$('.w-lightbox-backdrop').animate({'opacity': 0}, 200, function(){
      $(this).addClass('w-hidden');
    });
    this.isLightboxOpened = false;
    return false;
  },

  createPlayer: function(){   
    var that = this;
    that.player = new YT.Player('player', {
      height: '720',
      width: '1280',
      videoId: 'RQJ275nPHKM',
      playerVars:{
        controls: app.isMobile() ? 1 : 0,
        showInfo: 0,
        modestBranding: 0
      },
      events: {
        'onReady': that.onVideoReady,
        'onStateChange': that.onVideoStateChange
      }
    });
  },

  onVideoReady: function(){
    this.$('.w-lightbox-spinner').hide();
    if(this.isLightboxOpened){
      this.player.playVideo(); 
    }
  },

  onVideoStateChange: function(state){
    if(state.data === 0){
      this.closeVideo();
    }
  },

  showVideo: function(e){
    e.preventDefault();
    this.isLightboxOpened = true;
    var that = this;
    $('body').css('overflow','hidden');
    this.$('.w-lightbox-view').css('opacity', '1');
    this.$('.w-lightbox-backdrop').removeClass('w-hidden').animate({'opacity': 1}, 600, function(){
      if(!$.isEmptyObject(that.player) && typeof(that.player.playVideo) === 'function'){
        that.player.playVideo();  
      }
    });
  },

});
