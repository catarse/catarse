everything_ok = function(){
  var all_ok = true
  if(!ok('#about'))
    all_ok = false
  if(!ok('#rewards'))
    all_ok = false
  if(!ok('#links'))
    all_ok = false
  if(!contact_ok())
    all_ok = false
  if(!accepted_terms())
    all_ok = false
  if(all_ok){
    $('input[type=submit]').attr('disabled', false)
  } else {
    $('input[type=submit]').attr('disabled', true)
  }
}
ok = function(id){
  value = $(id).val()
  if(value && value.length > 0){
    $(id).addClass("ok").removeClass("error")
    return true
  } else {
    $(id).addClass("error").removeClass("ok")
    return false
  }
}
contact_ok = function(){
  value = $('#contact').val()
  re = /^[a-z0-9\._-]+@([a-z0-9][a-z0-9-_]*[a-z0-9-_]\.)+([a-z-_]+\.)?([a-z-_]+)$/
  if(value.match(re)){
    $('#contact').addClass("ok").removeClass("error")
    return true
  } else {
    $('#contact').addClass("error").removeClass("ok")
    return false
  }
}
accepted_terms = function(){
  return $('#accept').is(':checked')
}
$('#about').keyup(everything_ok)
$('#rewards').keyup(everything_ok)
$('#links').keyup(everything_ok)
$('#contact').keyup(everything_ok)
$('#accept').click(everything_ok)
$('input,textarea,select').live('focus', function(){
  $('p.inline-hints').hide()
  $(this).next('p.inline-hints').show()
})
$('#about').focus()
