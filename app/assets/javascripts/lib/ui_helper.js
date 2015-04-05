Skull.UI_helper = {
  setupResponsiveIframes: function($container) {
    this.$container = $container;
    this.$iframes = $("iframe[src^='//player.vimeo.com'], iframe[src^='//www.youtube.com']");
    this.$iframes.each(function() {
      if (!$(this).data('aspectRatio')) {
        $(this)
          .data('aspectRatio', this.height / this.width)
          .removeAttr('height')
          .removeAttr('width');
      }
    });
    this.updateIframeSize();
    this.windowResize();
  },

  windowResize: function() {
    var that = this;        
    $(window).resize(function() {
      that.updateIframeSize();
    });
  },

  updateIframeSize: function() {
    var newWidth = this.$container.width();
    if (newWidth) {
      this.$iframes.each(function() {
        var $el = $(this);
        $el
          .width(newWidth)
          .height(newWidth * $el.data('aspectRatio'));
      });
    } else {
      this.$iframes.each(function() {
        $(this)
          .removeAttr('height')
          .removeAttr('width');
      });
    }
  }
  
}
