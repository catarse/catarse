$('input[type=checkbox]').click(function(){
  if($(this).is(':checked')){
    $('input[type=submit]').attr('disabled', false)
  } else {
    $('input[type=submit]').attr('disabled', true)
  }
})
$('#show_tips a').click(function(e){
  e.preventDefault()
  $('#more_tips').effect("highlight", {color: "#dfd"}, 1500);
  $(this).hide()
})
$(document).ready(function(){
  if($('#login').length > 0){
    $('input[type=submit]').click(CATARSE.requireLogin)
  }
})
