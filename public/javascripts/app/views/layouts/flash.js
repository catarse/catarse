$(function(){
  setTimeout( function(){ $('.flash').slideDown('slow') }, 100)
  if( ! $('.flash a').length) setTimeout( function(){ $('.flash').slideUp('slow') }, 16000)
})
$(window).click(function(){ $('.flash').slideUp() })
