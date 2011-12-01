var zip_code_valid = null
everything_ok = function(){
  var all_ok = true
  if($('#backer_credits').val() == "false"){
    if(!ok('#user_full_name'))
      all_ok = false
    if(!email_ok())
      all_ok = false
    if(!zip_code_ok())
      all_ok = false
    if(!ok('#user_address_street'))
      all_ok = false
    if(!ok('#user_address_number'))
      all_ok = false
    if(!ok('#user_address_neighbourhood'))
      all_ok = false
    if(!ok('#user_address_city'))
      all_ok = false
    if(!ok('#user_address_state'))
      all_ok = false
    if(!phone_number_ok())
      all_ok = false
  }
  if(!accepted_terms())
    all_ok = false
  if(all_ok){
    $('#user_submit').attr('disabled', false)
  } else {
    $('#user_submit').attr('disabled', true)
  }
}
ok = function(id){
  var value = $(id).val()
  if(value && value.length > 0){
    $(id).addClass("ok").removeClass("error")
    return true
  } else {
    $(id).addClass("error").removeClass("ok")
    return false
  }
}
email_ok = function(){
  var value = $('#user_email').val()
  var re = /^[a-z0-9\._-]+@([a-z0-9][a-z0-9-_]*[a-z0-9-_]\.)+([a-z-_]+\.)?([a-z-_]+)$/
  if(value.match(re)){
    $('#user_email').addClass("ok").removeClass("error")
    return true
  } else {
    $('#user_email').addClass("error").removeClass("ok")
    return false
  }
}
phone_number_ok = function(){
  var value = $('#user_phone_number').val()
  var re = /^\([0-9]{2}\)[0-9]{4}-[0-9]{4}$/
  if(value.match(re)){
    $('#user_phone_number').addClass("ok").removeClass("error")
    return true
  } else {
    $('#user_phone_number').addClass("error").removeClass("ok")
    return false
  }
}
accepted_terms = function(){
  return $('#accept').is(':checked')
}
zip_code_ok = function(){
  if(zip_code_valid){
    $('#user_address_zip_code').addClass("ok").removeClass("error")
    return true
  } else if(/^[0-9]{5}-[0-9]{3}$/i.test($('#user_address_zip_code').val())) {
    if(!$('#user_address_zip_code').hasClass('loading'))
      $('#user_address_zip_code').removeClass("error").removeClass("ok")
    return true
  } else {
    if(!$('#user_address_zip_code').hasClass('loading'))
      $('#user_address_zip_code').addClass("error").removeClass("ok")
    return false
  }
}
verify_zip_code = function(){
  zip_code_valid = false
  if(/^[0-9]{5}-[0-9]{3}$/i.test($('#user_address_zip_code').val())) {
    $('#user_address_zip_code').removeClass("ok").removeClass("error").addClass('loading')
    $.get('/projects/cep/?cep='+$('#user_address_zip_code').val(), function(r){
      $('#user_address_zip_code').removeClass("loading")
      if(r.ok==true){
        zip_code_valid = true
        if(r.street != $('#user_address_street').val()){
          $('#user_address_street').val(r.street).effect("highlight", {}, 1500)
          $('#user_address_number').val(null).effect("highlight", {}, 1500)
          $('#user_address_complement').val(null).effect("highlight", {}, 1500)
          $('#user_address_number').focus()
        }
        if(r.neighbourhood != $('#user_address_neighbourhood').val())
          $('#user_address_neighbourhood').val(r.neighbourhood).effect("highlight", {}, 1500)
        if(r.city != $('#user_address_city').val())
          $('#user_address_city').val(r.city).effect("highlight", {}, 1500)
        if(r.state != $('#user_address_state').val())
          $('#user_address_state').val(r.state).effect("highlight", {}, 1500)
      } else {
        zip_code_valid = false
      }
      everything_ok()
    })
  }
  everything_ok()
}
$('#user_address_zip_code').mask("99999-999")

//Apply the mask when user use the browser autocomplete
$('#user_address_zip_code').change(function(){
  $(this).mask("99999-999");
});

$('#user_phone_number').mask("(99)9999-9999")
$('input[type=text]').keyup(everything_ok)
$('#user_address_zip_code').keyup(function(){ zip_code_valid = false; everything_ok() })
$('#user_address_zip_code').timedKeyup(verify_zip_code)
$('#user_address_complement').addClass("ok")
$('#accept').click(everything_ok)
$('select').change(everything_ok)
verify_zip_code()

$('#international_link').click(function(e){
  e.preventDefault()
  $('#international_link').parent().hide()
  $('#international_expanded').slideDown()
})
$('#accept_international').click(function(){
  $('#international_submit').attr('disabled', !$('#accept_international').is(':checked'))
})
