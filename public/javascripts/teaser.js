$('#email').keyup(function(){
  value = $('#email').val()
  re = /^[a-z0-9\._-]+@([a-z0-9][a-z0-9-_]*[a-z0-9-_]\.)+([a-z-_]+\.)?([a-z-_]+)$/
  if(value.match(re)){
    $('#email').addClass("ok").removeClass("error")
    $('input[type=submit]').attr('disabled', false)
  } else {
    $('#email').addClass("error").removeClass("ok")
    $('input[type=submit]').attr('disabled', true)
  }
})
