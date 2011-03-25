$('input[type=checkbox]').live('click', function(){
  var id = $(this).parent().parent().attr('id')
  var field = $(this).attr('id').split('__')[0]
  $.post('/projects/update_attribute_on_the_spot', {
    id: 'backer__' + field + '__' + id,
    value: ($(this).is(':checked') ? true : false)
  })
})
