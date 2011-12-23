$script.ready('final', function(){
  $('#project_embed .close').click(function(e){
    e.preventDefault()
    $('#project_embed').hide()
    $('.overlay').hide()
  })
  $("#project_embed textarea").click(function(e){
    e.preventDefault()
    $(this).select()
  })
})