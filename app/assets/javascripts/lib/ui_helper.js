var UIHelper = window.UIHelper = {
  setupResponsiveIframes: function($container) {
    var that = this;
    this.$container = $container;
    this.$iframes = $("iframe[src^='//player.vimeo.com'], iframe[src^='//www.youtube.com'], iframe[src^='https://www.youtube.com']");
    this.$iframes.each(function() {
      if (!$(this).data('aspectRatio')) {
        var height = this.height || $(this).height(),
            width = this.width || $(this).width();
        $(this)
          .data('aspectRatio', height / width)
          .removeAttr('height')
          .removeAttr('width');
      }
    });
    this.windowResize();
    //Prevents wrong container width calculation
    setTimeout(function(){
      that.updateIframeSize();  
    },0);
  },

  windowResize: function() {
    var that = this;        
    $(window).resize(function() {
      that.updateIframeSize();
    });
  },

  updateIframeSize: function() {
    var newWidth = this.$container.width();

    if(!this.$iframes){
      return;
    }

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
  
};