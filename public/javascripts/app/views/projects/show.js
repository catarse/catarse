CATARSE.loader.dependencies = ['app/collections/backers']

CATARSE.loader.load([
  'app/models/project', 
  'app/models/user', 
  'app/models/backer', 
  'app/collections/paginated', 
  'app/views/model', 
  'app/views/paginated', 
  'app/routers/project'
], 'initial_dependencies')

$script.ready('initial_dependencies', function() {
  CATARSE.loader.load(CATARSE.loader.dependencies, 'dependencies')
})

$script.ready('dependencies', function() {

  CATARSE.BackerView = CATARSE.ModelView.extend({
    template: _.template($('#backer_template').html())
  })
  CATARSE.BackersView = CATARSE.PaginatedView.extend({
  	modelView: CATARSE.BackerView,
  	emptyTemplate: _.template($('#empty_backers_template').html()),
  });

  CATARSE.project = new CATARSE.Project($('#project_description').data("project"))
  CATARSE.projectRouter = new CATARSE.ProjectRouter()

  $("#project_link").click(function(e){
    e.preventDefault()
    $(this).select()
  })
  $('#embed_link').click(function(e){
    e.preventDefault()
    $('#embed_overlay').show()
    $('#project_embed').fadeIn()
  })
  $('#project_embed .close').click(function(e){
    e.preventDefault()
    $('#project_embed').hide()
    $('#embed_overlay').hide()
  })
  $("#project_embed textarea").click(function(e){
    e.preventDefault()
    $(this).select()
  })
  $(document).ready(function(){
    if($('#login').length > 0){
      $('input[type=submit]').click(require_login)
    }
  })
  $('#rewards li.clickable').click(function(e){
    if($(e.target).is('a') || $(e.target).is('textarea') || $(e.target).is('button'))
      return true
    var url = $(this).find('input[type=hidden]').val()
    if($('#login').length > 0){
      $('#return_to').val(url)
      $('#login_overlay').show()
      $('#login').fadeIn()
    } else {
      window.location.href = url
    }
  })

})
