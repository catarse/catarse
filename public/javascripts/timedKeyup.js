$.fn.timedKeyup = function(handler, timeout){
  if(timeout == null)
    timeout = 300
  $(this).keyup(function(data){
      $(this).stopTime("keyup")
      $(this).oneTime(timeout, "keyup", handler, 100);
    })
}
