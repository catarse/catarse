$("input#user_submit").attr('disabled', true)
$('input,textarea').live('keypress', function(e){
  if (e.which == '13' && $("button:contains('OK')").attr('disabled')) {
    e.preventDefault();
  }
})
$('#user_feed input').live('keyup', function(){
  var value = $(this).val();
  var all_ok = false;
  if($(this).parent().hasClass('skip_feed_event')) {
    if(value == "" || value == null || value == undefined) {
      $(this).removeClass("empty").addClass("empty").removeClass("ok")
    }
    if(value.length < 6 || value.length > 128) {
      $(this).addClass("error").removeClass("ok")
      $("input#user_submit").attr('disabled', true)
    } else {
      $(this).addClass("ok").removeClass("error")
      $(this).removeClass("empty")
    }
    var input_passwords = $("input[type=password]", $(this).parent());
    if(input_passwords.hasClass("error") || input_passwords.hasClass("empty")) {
      $("input#user_submit").attr('disabled', true)
    } else {
      $("input#user_submit").attr('disabled', false)
    }
  } else {
    var re = /^[a-z0-9\._-]+@([a-z0-9][a-z0-9-_]*[a-z0-9-_]\.)+([a-z-_]+\.)?([a-z-_]+)$/
    if(value.match(re)){
      $(this).addClass("ok").removeClass("error")
      $("button:contains('OK')").attr('disabled', false)
    } else {
      $(this).addClass("error").removeClass("ok")
      $("button:contains('OK')").attr('disabled', true)
    }
  }
})
$('#content_header textarea').live('keyup', function(){
  var value = $(this).val()
  if(value.length <= 140){
    $(this).addClass("ok").removeClass("error")
    $("button:contains('OK')").attr('disabled', false)
  } else {
    $(this).addClass("error").removeClass("ok")
    $("button:contains('OK')").attr('disabled', true)
  }
})
$('input[type=checkbox]').click(function(){
  $.post('/users/update_attribute_on_the_spot', {
    id: 'user__' + $(this).attr('id') + '__' + $('#id').val(),
    value: ($(this).is(':checked') ? 1 : null)
  })
})
