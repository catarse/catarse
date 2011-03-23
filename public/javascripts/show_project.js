$("#project_link").click(function(e){
  e.preventDefault()
  $(this).select()
})
$('#embed_link').click(function(e){
  e.preventDefault()
  $('#embed_overlay').show()
  $('#project_embed').fadeIn()
})
$(document).ready(function(){
  if($('#login').length > 0){
    $('input[type=submit]').click(require_login)
  }
})
$('#rewards li.clickable').click(function(e){
  if($(e.target).is('a') || $(e.target).is('textarea') || $(e.target).is('button'))
    return true
  url = $(this).find('input[type=hidden]').val()
  if($('#login').length > 0){
    $('#return_to').val(url)
    $('#login_overlay').show()
    $('#login').fadeIn()
  } else {
    window.location.href = url
  }
})
