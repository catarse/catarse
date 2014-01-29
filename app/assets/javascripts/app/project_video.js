$(".video-thumb").click(function() {
	$(".channel-bio").toggle();
	$(".big-video").toggle();
	$(".big-video-close").toggle("easein");
});

$(".big-video-close").click(function() {
	$(".big-video").toggle();
	$(".big-video-close").toggle();
	$(".channel-bio").toggle();
});