var return_to = null
$('#login_link').click(function(){
  $('.page_overlay').show()
  $('#login').fadeIn()
})
$('#new_project_link').click(function(){
  $('#return_to').val("/projects/new")
  $('.page_overlay').show()
  $('#login').fadeIn()
})
$('.close').click(function(){
  $('#login').hide()
  $('.page_overlay').hide()
})
$('#login a').click(function(e){
  e.preventDefault()
  if($(this).hasClass('disabled'))
    return
  $('#login a').addClass('disabled')
  $('#provider').val($(this).attr('href'))
  $('#login form').submit()
})