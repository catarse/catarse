$('#explore_quick a').click(function(e){
  e.preventDefault()
  $('a.selected').removeClass('selected')
  $(this).addClass('selected')
  id = /^menu_(\w+)$/.exec($(this).attr('id'))
  id = id[1]
  console.log(id)
  $('#explore_results .results').hide()
  $('#explore_'+id).show()
})
$('#explore_categories a').click(function(e){
  e.preventDefault()
  $('a.selected').removeClass('selected')
  $(this).addClass('selected')
  category = $(this).html()
  $('#explore_results .results').hide()
  $('#explore_all .project_box').show()
  $('#explore_all .project_category').each(function(){
    if($(this).html() != category)
      $(this).parent().parent().hide()
  })
  $('#explore_all').show()
})

