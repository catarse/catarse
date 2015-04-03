Skull.UI_helper = {

	makeVideosResponsive: function($container){

		console.log("making videos responsive");
	    
		this.$container = $container;

		this.$videos = $("iframe[src^='//player.vimeo.com'], iframe[src^='//www.youtube.com']");

	    this.$videos.each(function() {
	      $(this)
	        .data('aspectRatio', this.height / this.width)
	        .removeAttr('height')
	        .removeAttr('width');
	    });

	    this.updateVideoSize();
	    this.windowResize();
  	},

  	windowResize: function(){
  		var that = this;
  		// When the window is resized
		$(window).resize(function() {

		  that.updateVideoSize();

		});

  	},

	updateVideoSize: function(){

		console.log("Updating video size");

		var newWidth = this.$container.width();
		  
		this.$videos.each(function() {
		  var $el = $(this);
		  $el
		    .width(newWidth)
		    .height(newWidth * $el.data('aspectRatio'));
		});

	}
}