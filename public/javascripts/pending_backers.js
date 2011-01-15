$('input[type=checkbox]').click(function(){
  id = $(this).parent().attr('id')
  $.post('/projects/update_attribute_on_the_spot', {
    id: 'backer__' + $(this).attr('id') + '__' + id,
    value: ($(this).is(':checked') ? 1 : null)
  })
})
