everything_ok = function(){
  var all_ok = true
  check_credits()
  if(!value_ok())
    all_ok = false
  if(!reward_ok())
    all_ok = false
  if(all_ok){
    $('#backer_submit').attr('disabled', false)
  } else {
    $('#backer_submit').attr('disabled', true)
  }
}
check_credits = function(){
  var credits = parseInt($('#credits').val())
  var value = parseInt($('#backer_value').val())
  if(value > credits){
    $('#backer_credits').attr('checked', false)
    $('#backer_credits').attr('disabled', true)
  } else {
    $('#backer_credits').attr('disabled', false)
  }
}
reward_ok = function(){
  if(!$('input[type=radio]:checked').val())
    return false
  var reward = $('input[type=radio]:checked')
  var id = /^backer_reward_id_(\d+)$/.exec(reward.attr('id'))
  id = parseFloat(id[1])
  var minimum = rewards[id]
  if(minimum){
    var value = $('#backer_value').val()
    if(!(/^(\d+)$/.test(value)) || (parseInt(value) < minimum)){
      return false
    }
  }
  return true
}
value_ok = function(){
  var value = $('#backer_value').val()
  if(/^(\d+)$/.test(value) && parseInt(value) >= 10){
    $('#backer_value').addClass("ok").removeClass("error")
    return true
  } else {
    $('#backer_value').addClass("error").removeClass("ok")
    $('#backer_reward_id_0').attr("checked", true)
    return false
  }
}
$('input[type=radio]').click(function(){
  var id = /^backer_reward_id_(\d+)$/.exec($(this).attr('id'))
  id = parseFloat(id[1])
  var minimum = rewards[id]
  if(minimum){
    var value = $('#backer_value').val()
    if(!(/^(\d+)$/.test(value)) || (parseInt(value) < minimum)){
      $('#backer_value').val(parseInt(minimum))
    }
  }
  $('li.radio ol li').removeClass('selected')
  $(this).parent().parent().addClass('selected')
  everything_ok()
})
$('#backer_value').keyup(function(){
  var reward = $('input[type=radio]:checked')
  if(reward.val()){
    var id = /^backer_reward_id_(\d+)$/.exec(reward.attr('id'))
    id = parseFloat(id[1])
    var minimum = rewards[id]
    if(minimum){
      var value = $('#backer_value').val()
      if(!(/^(\d+)$/.test(value)) || (parseInt(value) < minimum)){
        $('#backer_reward_id_0').attr("checked", true)
      }
    }
  }
  everything_ok()
})
$('#backer_value').numeric(false)
$('.sold_out').parent().find('input[type=radio]').attr('disabled', true)
if($('input[type=radio]:checked').length == 0)
  $('#backer_reward_id_0').attr("checked", true)
if($('#backer_value').val())
  everything_ok()
$('#backer_value').focus()
$('#backer_anonymous').click(function(){
  if($(this).is(':checked')){
    $('#anonymous_warning').slideDown(200)
  } else {
    $('#anonymous_warning').slideUp(200)
  }
})
$('input[type=radio]:checked').parent().parent().addClass('selected')