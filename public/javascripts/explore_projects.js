$('#explore_quick a').click(function(e){
  e.preventDefault()
  $('a.selected').removeClass('selected')
  $(this).addClass('selected')
  var id = /^menu_(\w+)$/.exec($(this).attr('id'))
  id = id[1]
  $('#explore_results .results').hide()
  $('#explore_'+id).show()
})
$('#explore_categories a').click(function(e){
  e.preventDefault()
  $('a.selected').removeClass('selected')
  $(this).addClass('selected')
  var category = $(this).html()
  $('#explore_results .results').hide()
  $('#explore_all .project_box').show()
  $('#explore_all .project_category').each(function(){
    if($(this).html() != category)
      $(this).parent().parent().hide()
  })
  $('#explore_all').show()
})
if($('#explore_projects .selected').length == 0){
  $('#menu_recommended').addClass('selected')
}
$('#explore_projects .selected').click()

