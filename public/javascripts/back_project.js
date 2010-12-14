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
  if($('input[type=radio]:checked').val()){
    return true
  } else {
    return false
  }
}
value_ok = function(){
  value = $('#backer_value').val()
  if(/^(\d+)(\,\d{1,2})?$/.test(value) && parseFloat(value.replace(',', '.')) >= 10){
    $('#backer_value').addClass("ok").removeClass("error")
    $('input[type=radio]').attr("disabled", true)
    $('#backer_reward_id_0').attr("disabled", false)
    $('input[type=radio]').each(function(){
      id = /^backer_reward_id_(\d+)$/.exec($(this).attr('id'))
      id = parseFloat(id[1])
      minimum = rewards[id]
      if(minimum){
        if(parseFloat(value.replace(',', '.')) >= minimum){
          $(this).attr("disabled", false)
        } else {
          if($(this).is(':checked'))
            $('#backer_reward_id_0').attr("checked", true)
          $(this).attr("disabled", true)
        }
      }
    })
    return true
  } else {
    $('#backer_value').addClass("error").removeClass("ok")
    $('input[type=radio]').attr("disabled", true)
    $('#backer_reward_id_0').attr("disabled", false)
    $('#backer_reward_id_0').attr("checked", true)
    return false
  }
}
$('input[type=radio]').click(everything_ok)
$('#backer_value').keyup(everything_ok)
$('#backer_value').numeric(',')
$('#backer_value').focus()
$('input[type=radio]').attr("disabled", true)
$('#backer_reward_id_0').attr("disabled", false)
$('#backer_reward_id_0').attr("checked", true)
