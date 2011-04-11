var size = 312
$('.next').click(function(e){
  e.preventDefault()
  var position = parseInt($(this).parent().parent().find('#position').val())
  position -= 3
  slide($(this).parent().parent().find('.slider'), position)
})
$('.prev').click(function(e){
  e.preventDefault()
  var position = parseInt($(this).parent().parent().find('#position').val())
  position += 3
  slide($(this).parent().parent().find('.slider'), position)
})
slide = function(slider, position){
  var total_projects = slider.parent().find('#total_projects').val()
  if(position <= 3-total_projects)
    position = 3-total_projects
  if(position > 0)
    position = 0
  var prev = slider.parent().parent().parent().find('.prev')
  var next = slider.parent().parent().parent().find('.next')
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
$('.slider').each(function(){
  slide($(this), 0)
})
