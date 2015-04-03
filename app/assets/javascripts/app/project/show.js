App.addChild('ProjectShow', _.extend({
  el: 'body[data-action="show"][data-controller-name="projects"]',

  activate: function(){

    $videos = $("iframe[src^='//player.vimeo.com'], iframe[src^='//www.youtube.com']"),
    
    $container = $(".project-about");

    this.makeVideosResponsive($videos, $container);

  },

  events: {
    'resize window' : 'updateVideoSize'
  },

  makeVideosResponsive: function($videos){

    $videos.each(function() {
      
      $(this)
        .data('aspectRatio', this.height / this.width)
        .removeAttr('height')
        .removeAttr('width');
    
    });


  },

  updateVideoSize: function(e){

    var newWidth = this.$container.width();
      
    this.$allVideos.each(function() {
    
      var $el = $(this);
    
      $el
        .width(newWidth)
        .height(newWidth * $el.data('aspectRatio'));

    });

    window.dispatchEvent(e);

  }

}));



