$('.notification .close').click(function(e){
  e.preventDefault()
  id = $(this).parent().attr('id').split('_')[1]
  $.post('/users/update_attribute_on_the_spot', {
    id: 'notification__dismissed__' + id,
    value: true
  })
  $(this).parent().slideUp(function(){
    if($('#pre_header:has(.back_notice:visible)').length == 0 && $('#pre_header:has(.notification:visible)').length == 0){
      $('#pre_header').slideUp()
    }
  })
})

