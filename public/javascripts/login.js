var return_to = null
$('#login_link').click(function(){
  $('.overlay').show()
  $('#login').fadeIn()
})
$('#new_project_link').click(function(){
  $('#return_to').val("/projects/guidelines")
  $('.overlay').show()
  $('#login').fadeIn()
})
$('.close').click(function(){
  $('#login').hide()
  $('.overlay').hide()
})
$('a.provider').click(function(e){
  e.preventDefault()
  if($(this).hasClass('disabled'))
    return
  $('a.provider').addClass('disabled')
  $('#provider').val($(this).attr('href'))
  $('#login form').submit()
})