$('#user_menu_link').click(function(e){
  e.preventDefault()
  if($('#user_menu').is(':hidden')) {
    $('#user_menu').show()
    if($('#user_menu').css('width') > $('#user_menu_link').css('width')) {
      $('#user_menu').addClass('user_menu_border')
    } else {
      $('#user_menu').css('width', $('#user_menu_link').css('width'))
    }
    $('#user_menu_link').addClass('hover')
  } else {
    $('#user_menu').hide()
    $('#user_menu_link').removeClass('hover')
  }
})
