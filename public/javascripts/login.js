$('#login_link').click(function(){
  $('.page_overlay').show()
  $('#login').fadeIn()
})
$('.close').click(function(){
  $('#login').hide()
  $('.page_overlay').hide()
})
