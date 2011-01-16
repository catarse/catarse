$('input[type=checkbox]').click(function(){
  id = $(this).parent().attr('id')
  field = $(this).attr('id').split('_')[0]
  $.post('/projects/update_attribute_on_the_spot', {
    id: 'project__' + field + '__' + id,
    value: ($(this).is(':checked') ? 1 : null)
  })
})
