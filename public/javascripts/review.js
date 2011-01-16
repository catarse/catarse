$('input[type=checkbox]').click(function(){
  if($(this).is(':checked')){
    $('input[type=submit]').attr('disabled', false)
  } else {
    $('input[type=submit]').attr('disabled', true)
  }
})
