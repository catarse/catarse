$('input[type=checkbox]').click(function(){
  if($(this).is(':checked')){
    $('input[type=submit]').attr('disabled', false)
  } else {
    $('input[type=submit]').attr('disabled', true)
  }
})
$('#show_tips a').click(function(){
  $(this).hide()
  $('#more_tips').show()
})