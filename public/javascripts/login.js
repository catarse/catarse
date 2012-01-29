require_login = function(e){
  e.preventDefault()
  var url = null
  if($(this).is('a')){
    url = $(this).attr('href')
  } else {
    url = $('input[type=submit]').parentsUntil('form').parent().attr('action')
  }
  $('#return_to').val(url)
  $('#login_overlay').show()
  $('.another_social').hide();
  $('#login').fadeIn()
}
var return_to = null
$('#login_link,#signup_link,.login_link').live('click', function(e){
  e.preventDefault()
  $('#return_to').val(location.href)
  $('#login_overlay').show()
  $('.another_social').hide();
  $('#login').fadeIn()
})
if($('#login').length > 0){
  $('#new_project_link,#ghost_project_link').click(require_login)
}
$('#login .close').click(function(e){
  e.preventDefault()
  $('#return_to').val(null)
  $('#login').hide()
  $('#login_overlay').hide()
})
$('a.provider').click(function(e){
  e.preventDefault()
  if($(this).hasClass('disabled'))
    return
  $('a.provider').addClass('disabled')
  $('#provider').val($(this).attr('href'))
  $('#login form').submit()
})

$("#login_with_another_social").click(function(e){
  e.preventDefault();
  if($('#login_form_with_email').css('display') == 'block') {
    $('#login_form_with_email').slideUp('fast', function(){
      $('.another_social').slideDown('fast');
      $('fieldset.remember_me_social').show();
    })
  } else if ($('#new_email_account').css('display') == 'block') {
    $('#new_email_account').slideUp('fast', function(){
      $('.another_social').slideDown('fast');
    })
  } else if ($('#forgot_password_form').css('display') == 'block') {
    $('#forgot_password_form').slideUp('fast', function(){
      $('.another_social').slideDown('fast');
    })
  } else {
    $('.another_social').slideDown('fast');
  }
  $('fieldset.remember_me_social').show();
});

$("#login_with_mail").click(function(e){
  e.preventDefault();
  if($('.another_social').css('display') == 'block') {
    $('.another_social').slideUp('fast', function(){
      $('#login_form_with_email').slideDown('fast');
    })
  } else {
    $('#login_form_with_email').slideDown('fast');
  }
  $('fieldset.remember_me_social').hide();
});

$('a.new_registration_link').click(function(e){
  e.preventDefault();
  if($('#login_form_with_email').css('display') == 'block') {
    $('#login_form_with_email').slideUp('fast', function(){
      $('#new_email_account').slideDown('fast');
    });
  } else if($('#forgot_password_form').css('display') == 'block') {
    $('#forgot_password_form').slideUp('fast', function(){
      $('#new_email_account').slideDown('fast');
    });
  } else { $('#new_email_account').slideDown('fast'); }
});

$('a.new_session_link').click(function(e){
  e.preventDefault();
  if($('#new_email_account').css('display') == 'block') {
    $('#new_email_account').slideUp('fast', function(){
      $('#login_form_with_email').slideDown('fast');
    });
  } else if($('#forgot_password_form').css('display') == 'block') {
    $('#forgot_password_form').slideUp('fast', function(){
      $('#login_form_with_email').slideDown('fast');
    });
  } else { $('#login_form_with_email').slideDown('fast'); }
});

$('a.forgot_password_link').click(function(e){
  e.preventDefault();
  if($('#new_email_account').css('display') == 'block') {
    $('#new_email_account').slideUp('fast', function(){
      $('#forgot_password_form').slideDown('fast');
    });
  } else if($('#login_form_with_email').css('display') == 'block') {
    $('#login_form_with_email').slideUp('fast', function(){
      $('#forgot_password_form').slideDown('fast');
    });
  } else { $('#forgot_password_form').slideDown('fast'); }
});