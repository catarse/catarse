require_login = function(e){
  e.preventDefault()
  if($(this).is('a')){
    url = $(this).attr('href')
  } else {
    url = $('input[type=submit]').parentsUntil('form').parent().attr('action')
  }
  $('#return_to').val(url)
  $('#login_overlay').show()
  $('#login').fadeIn()
}
var return_to = null
$('#login_link,#signup_link').click(function(e){
  e.preventDefault()
  $('#login_overlay').show()
  $('#login').fadeIn()
})
if($('#login').length > 0){
  $('#new_project_link,#ghost_project_link').click(require_login)
}
$('#login .close').click(function(e){
  e.preventDefault()
  $('#login').hide()
  $('#login_overlay').hide()
})
$('a.provider').click(function(e){
  e.preventDefault()
  if($(this).hasClass('disabled'))
    return
  $('a.provider').addClass('disabled')
  $('#provider').val($(this).attr('href'))
  $('#login form').submit()
})

