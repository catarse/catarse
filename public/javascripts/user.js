$('#user').hover(function(){
  $('#user_menu').show()
  if($('#user_menu').css('width') > $('#user_menu_link').css('width')) {
    $('#user_menu').addClass('user_menu_border')
  } else {
    $('#user_menu').css('width', $('#user_menu_link').css('width'))
  }
  $('#user_menu_link').addClass('hover')
}, function(){
  $('#user_menu').hide()
  $('#user_menu_link').removeClass('hover')
})