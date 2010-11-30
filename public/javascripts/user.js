$('#user').hover(function(){
  $('#user_menu').show()
  $('#user_menu_link').addClass('hover')
}, function(){
  $('#user_menu').hide()
  $('#user_menu_link').removeClass('hover')
})