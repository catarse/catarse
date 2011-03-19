everything_ok = function(){
  var all_ok = true
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
reward_ok = function(){
  if(!$('input[type=radio]:checked').val())
    return false
  reward = $('input[type=radio]:checked')
  id = /^backer_reward_id_(\d+)$/.exec(reward.attr('id'))
  id = parseFloat(id[1])
  minimum = rewards[id]
  if(minimum){
    value = $('#backer_value').val()
    if(!(/^(\d+)$/.test(value)) || (parseInt(value) < minimum)){
      return false
    }
  }
  return true
}
value_ok = function(){
  value = $('#backer_value').val()
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
  id = /^backer_reward_id_(\d+)$/.exec($(this).attr('id'))
  id = parseFloat(id[1])
  minimum = rewards[id]
  if(minimum){
    value = $('#backer_value').val()
    if(!(/^(\d+)$/.test(value)) || (parseInt(value) < minimum)){
      $('#backer_value').val(parseInt(minimum))
    }
  }
  everything_ok()
})
$('#backer_value').keyup(function(){
  reward = $('input[type=radio]:checked')
  if(reward.val()){
    id = /^backer_reward_id_(\d+)$/.exec(reward.attr('id'))
    id = parseFloat(id[1])
    minimum = rewards[id]
    if(minimum){
      value = $('#backer_value').val()
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

