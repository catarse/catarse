var ProjectRouter = Backbone.Router.extend({
	routes: {
		'': 'about',
		'about': 'about',
		'updates': 'updates',
		'backers': 'backers',
		'comments': 'comments'
	},
	
	initialize: function(options) {
    typeof(options) != 'undefined' || (options = {})
		this.project = options.project
		this.locale = options.locale
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
		this.backersView = new BackersView({
			collection: this.project.backers,
			loading: $("#loading"),
			locale: this.locale,
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
