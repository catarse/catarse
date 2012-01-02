CATARSE.BackerView = CATARSE.ModelView.extend({
  template: _.template($('#backer_template').html())
})
CATARSE.BackersView = CATARSE.PaginatedView.extend({
	modelView: CATARSE.BackerView,
	emptyTemplate: _.template($('#empty_backers_template').html()),
})

CATARSE.ProjectRouter = Backbone.Router.extend({
	routes: {
		'': 'about',
		'about': 'about',
		'updates': 'updates',
		'backers': 'backers',
		'comments': 'comments'
	},
	
	initialize: function(options) {
    typeof(options) != 'undefined' || (options = {})
	},
	
	about: function() {
		this.selectItem("about")
	},

	updates: function() {
		this.selectItem("updates")
	},

	comments: function() {
		this.selectItem("comments")
	},

	backers: function() {
		this.selectItem("backers")
		this.backersView = new CATARSE.BackersView({
			collection: CATARSE.project.backers,
			loading: $("#loading"),
			el: $("#project_backers")
		})
	},
	
	selectItem: function(item) {
		$("#project_content .content").hide()
		$("#project_content #project_" + item + ".content").show()
		var link = $("#project_menu #" + item + "_link")
		link.parent().parent().find('li').removeClass('selected')
    link.parent().addClass('selected')
	}
	
})

CATARSE.project = new CATARSE.Project($('#project_description').data("project"))
CATARSE.projectRouter = new CATARSE.ProjectRouter()

$('#show_formatting_tips').click(function(event){
  event.preventDefault()
  $('#show_formatting_tips').hide()
  $('#formatting_tips').slideDown()
})
$('#project_updates [type=submit]').attr('disabled', true)
$('#project_updates [type=text],textarea').keyup(function(){
  if($('#project_updates [type=text]').val().length > 0 && $('#project_updates textarea').val().length > 0)
    $('#project_updates [type=submit]').attr('disabled', false)
  else
    $('#project_updates [type=submit]').attr('disabled', true)
})

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
