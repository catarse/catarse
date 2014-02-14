$(".video-thumb").click(function() {
	$(".channel-bio").toggle();
	$(".big-video").slideDown( "slow", function() {
		$('html,body').animate({scrollTop: $(".big-video").offset().top},'slow');
		$(".video").toggle();
	});
	$(".big-video-close").toggle("easein");
});

$(".big-video-close").click(function() {
	$(".big-video").slideUp( "slow", function() {
		$(".big-video-close").toggle();
		$(".channel-bio").slideDown();
		$('html,body').animate({scrollTop: 0},'slow');
	});
});