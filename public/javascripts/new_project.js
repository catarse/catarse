everything_ok = function(){
  var all_ok = true
  if(!ok('#project_name'))
    all_ok = false
  if(!video_ok())
    all_ok = false
  if(!ok('#project_about'))
    all_ok = false
  if(!ok('#project_category_id'))
    all_ok = false
  if(!goal_ok())
    all_ok = false
  if(!deadline_ok())
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
  value = $(id).val()
  if(value && value.length > 0){
    $(id).addClass("ok").removeClass("error")
    return true
  } else {
    $(id).addClass("error").removeClass("ok")
    return false
  }
}
var video_valid = false
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
goal_ok = function(){
  value = $('#project_goal').val()
  if(/^(\d+)(\,\d{1,2})?$/.test(value)){
    $('#project_goal').addClass("ok").removeClass("error")
    return true
  } else {
    $('#project_goal').addClass("error").removeClass("ok")
    return false
  }
}
deadline_ok = function(){
  value = /^(\d{2})\/(\d{2})\/(\d{4})?$/.exec($('#project_deadline').val())
  if(value && value.length == 4) {
    year = parseInt(value[3])
    month = parseInt(value[2])-1
    day = parseInt(value[1])
    date = new Date(year, month, day)
    if(((day==date.getDate()) && (month==date.getMonth()) && (year==date.getFullYear()))){
      $('#project_deadline').addClass("ok").removeClass("error")
      return true
    } else {
      $('#project_deadline').addClass("error").removeClass("ok")
      return false
    }
  } else {
    $('#project_deadline').addClass("error").removeClass("ok")
    return false
  }
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
$('#project_deadline').keyup(everything_ok)
$('#accept').click(everything_ok)

$('#project_goal').numeric(',')
$('#project_deadline').datepicker({
  altFormat: 'dd/mm/yy',
  onSelect: everything_ok
})
