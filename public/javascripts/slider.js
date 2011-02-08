var size = 280
$('.next').click(function(e){
  e.preventDefault()
  var position = $(this).parent().parent().find('#position').val()
  position--
  slide($(this).parent().parent().find('.slider'), position)
})
$('.prev').click(function(e){
  e.preventDefault()
  var position = $(this).parent().parent().find('#position').val()
  position++
  slide($(this).parent().parent().find('.slider'), position)
})
slide = function(slider, position){
  var total_projects = slider.parent().find('#total_projects').val()
  prev = slider.parent().parent().parent().find('.prev')
  next = slider.parent().parent().parent().find('.next')
  slider.animate({'margin-left': (position*size) + 'px'})
  if(position==0)
    prev.attr('disabled', true)
  else
    prev.attr('disabled', false)
  if(position==3-total_projects)
    next.attr('disabled', true)
  else
    next.attr('disabled', false)
  slider.parent().find('#position').val(position)
}
slide($('.slider'), 0)
