window.ProjectController = Backbone.Router.extend({
	routes: {
		'': 'about',
		'updates': 'updates',
		'backers': 'backers',
		'comments': 'comments'
	},
	
	initialize: function() {
		this.aboutView = new ProjectAboutView();
	},
	
	about: function() {
		var $container = $('#project_content');
		$container.empty();
		$container.append(this.aboutView.render().el);
	}
})
