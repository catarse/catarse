$("#project_link").click(function(){
  $(this).select()
})
$(document).ready(function(){
  if($('#login').length > 0){
    $('input[type=submit]').click(require_login)
  }
})
