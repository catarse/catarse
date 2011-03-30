$("#project_link").click(function(e){
  e.preventDefault()
  $(this).select()
})
$('#embed_link').click(function(e){
  e.preventDefault()
  $('#embed_overlay').show()
  $('#project_embed').fadeIn()
})
$(document).ready(function(){
  if($('#login').length > 0){
    $('input[type=submit]').click(require_login)
  }
})
$('#rewards li.clickable').click(function(e){
  if($(e.target).is('a') || $(e.target).is('textarea') || $(e.target).is('button'))
    return true
  var url = $(this).find('input[type=hidden]').val()
  if($('#login').length > 0){
    $('#return_to').val(url)
    $('#login_overlay').show()
    $('#login').fadeIn()
  } else {
    window.location.href = url
  }
})
$('#project_menu a').click(function(e){
  e.preventDefault()
  $('#project_menu_content .project_content').hide()
  $('#project_'+ $(this).attr('id')).show()
  $('#project_menu .selected').removeClass('selected')
  $(this).addClass('selected')
})
$('#project_comments input[type=submit]').click(function(e){
  e.preventDefault()
  $('#project_comments input[type=submit]').attr('disabled', true)
  $('#comment_comment').attr('disabled', true)
  $.post('/projects/create_comment', {
    authenticity_token: $('#project_comments input[name=authenticity_token]').val(),
    commentable_type: 'Project',
    commentable_id: $('#project_id').val(),
    comment: $('#comment_comment').val()
  }, function(r){
    $('#project_comments input[type=submit]').attr('disabled', false)
    $('#comment_comment').attr('disabled', false)
    if(r.ok){
      $('#comment_comment').val('')
      console.log(r)
    } else {
      console.log("Erro!")
      console.log(r)
    }
  })
})