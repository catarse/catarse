$script.ready('final', function(){
  $('.back_notice .close').click(function(e){
    e.preventDefault()
    var id = $(this).parent().attr('id').split('_')[2]
    $.post('/projects/update_attribute_on_the_spot', {
      id: 'backer__display_notice__' + id,
      value: false
    })
    $(this).parent().slideUp(function(){
      if($('#pre_header:has(.back_notice:visible)').length == 0 && $('#pre_header:has(.notification:visible)').length == 0){
        $('#pre_header').slideUp()
      }
    })
  })
})
