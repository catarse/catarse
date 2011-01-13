$("#project_link").click(function(e){
  e.preventDefault()
  $(this).select()
})
$('#embed_link').click(function(e){
  e.preventDefault()
  $('.overlay').show()
  $('#project_embed').fadeIn()
})
$(document).ready(function(){
  if($('#login').length > 0){
    $('input[type=submit]').click(require_login)
  }
})
