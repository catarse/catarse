$('#add_reward').click(function(e){
  e.preventDefault()
  var new_reward = '<div class="reward">' + $($('.reward')[0]).html() + '</div>'
  new_reward = new_reward.replace(/\_0\_/g, '_' + rewards_id + '_')
  new_reward = new_reward.replace(/\[0\]/g, '[' + rewards_id + ']')
  new_reward = $(new_reward)
  new_reward.find('input').val(null)
  new_reward.find('textarea').html(null)
  new_reward.find('input').numeric(false)
  new_reward.find('input, textarea').removeClass('ok').removeClass('error')
  $('#rewards_wrapper').append(new_reward)
  new_reward.find('textarea').focus()
  rewards_count++
  rewards_id++
})
var video_valid = null
everything_ok = function(){
  var all_ok = true
  if(video_valid == null) {
    all_ok = false
    verify_video()
  }
  if(!ok('#project_name'))
    all_ok = false
  if(!video_ok())
    all_ok = false
  if(!ok('#project_about'))
    all_ok = false
  if(!headline_ok())
    all_ok = false
  if(!ok('#project_category_id'))
    all_ok = false
  if(!goal_ok())
    all_ok = false
  if(!expires_at_ok())
    all_ok = false
  if(!rewards_ok())
    all_ok = false
  if(!accepted_terms())
    all_ok = false
  if(all_ok){
    $('#project_submit').attr('disabled', false)
  } else {
    $('#project_submit').attr('disabled', true)
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
verify_video = function(){
  video_valid = false
  if(/http:\/\/(www\.)?vimeo.com\/(\d+)/.test($('#project_video_url').val())) {
    $('#project_video_url').removeClass("ok").removeClass("error").addClass('loading')
    $.get('/projects/vimeo/?url='+$('#project_video_url').val(), function(r){
      $('#project_video_url').removeClass("loading")
      if(r.id==false){
        video_valid = false
      } else {
        video_valid = true
      }
      everything_ok()
    })
  }
  everything_ok()
}
video_ok = function(){
  if(video_valid){
    $('#project_video_url').addClass("ok").removeClass("error")
    return true
  } else {
    if(!$('#project_video_url').hasClass('loading'))
      $('#project_video_url').addClass("error").removeClass("ok")
    return false
  }
}
headline_ok = function(){
  var value = $('#project_headline').val()
  if(value && value.length > 0 && value.length <= 140){
    $('#project_headline').addClass("ok").removeClass("error")
    return true
  } else {
    $('#project_headline').addClass("error").removeClass("ok")
    return false
  }
}
goal_ok = function(){
  var value = $('#project_goal').val()
  if(/^(\d+)$/.test(value) && parseInt(value) > 0){
    $('#project_goal').addClass("ok").removeClass("error")
    return true
  } else {
    $('#project_goal').addClass("error").removeClass("ok")
    return false
  }
}
expires_at_ok = function(){
  var value = /^(\d{2})\/(\d{2})\/(\d{4})?$/.exec($('#project_expires_at').val())
  if(value && value.length == 4) {
    var year = parseFloat(value[3])
    var month = parseFloat(value[2])-1
    var day = parseFloat(value[1])
    var date = new Date(year, month, day)
    var current_date = new Date()
    if(((day==date.getDate()) && (month==date.getMonth()) && (year==date.getFullYear())) && date > current_date){
      $('#project_expires_at').addClass("ok").removeClass("error")
      return true
    } else {
      $('#project_expires_at').addClass("error").removeClass("ok")
      return false
    }
  } else {
    $('#project_expires_at').addClass("error").removeClass("ok")
    return false
  }
}
rewards_ok = function(){
  var okey = true
  $('.reward input').each(function(){
    if(/^(\d+)$/.test($(this).val())){
      if(/minimum_value/.test($(this).attr('id'))){
        if(parseInt($(this).val()) > 0) {
          $(this).addClass("ok").removeClass("error")
        } else {
          $(this).addClass("error").removeClass("ok")
          okey = false
        }
      } else {
        $(this).addClass("ok").removeClass("error")
      }
    } else {
      if(/maximum_backers/.test($(this).attr('id')) && (!$(this).val())){
        $(this).addClass("ok").removeClass("error")
      } else {
        $(this).addClass("error").removeClass("ok")
        okey = false
      }
    }
  })
  $('.reward textarea').each(function(){
    if($(this).val() && $(this).val().length > 0){
      $(this).addClass("ok").removeClass("error")
    } else {
      $(this).addClass("error").removeClass("ok")
      okey = false
    }
  })
  return okey
}
accepted_terms = function(){
  return $('#accept').is(':checked')
}
$('#project_name').keyup(everything_ok)
$('#project_video_url').keyup(function(){ video_valid = false; everything_ok() })
$('#project_video_url').timedKeyup(verify_video)
$('#project_about').keyup(everything_ok)
$('#project_category_id').change(everything_ok)
$('#project_goal').keyup(everything_ok)
$('#project_expires_at').keyup(everything_ok)
$('#project_headline').keyup(everything_ok)
$('#accept').click(everything_ok)
$('.reward input,.reward textarea').live('keyup', everything_ok)

$('#project_goal').numeric(false)
$('.reward input').numeric(false)
$('#project_expires_at').datepicker({
  altFormat: 'dd/mm/yy',
  onSelect: everything_ok
})
$('input,textarea,select').live('focus', function(){
  $('p.inline-hints').hide()
  $(this).next('p.inline-hints').show()
})
$('.reward').live('mouseover', function(){
  $('.remove_reward').hide()
  if(rewards_count > 1){
    $(this).find('.remove_reward').show()
  }
})
$('.reward').live('mouseout', function(){
  $(this).find('.remove_reward').hide()
})
$('.remove_reward').live('click', function(e){
  e.preventDefault()
  if(rewards_count > 1){
    reward = $(this).parentsUntil('.reward').parent()
    reward.remove()
    rewards_count--
  }
})
$('#project_name').focus()
$('textarea').maxlength()
