window.ProjectPage = Backbone.Router.extend({
	routes: {
		'': 'about',
		'about': 'about',
		'updates': 'updates',
		'backers': 'backers',
		'comments': 'comments'
	},
	
	initialize: function() {
		this.container = $('#project_content');
		this.aboutView = new ProjectAboutView();
		this.project = project;
		
		this.backersView = new BackersView({
			collection: this.project.backers,
			container: this.container
		});
	},
	
	about: function() {
		this.container.empty();
		this.container.append(this.aboutView.render().el);
	},

	backers: function() {
		$("#loading img").show();
		this.backersView.collection.fetch();
		this.container.empty();
		this.container.append(this.backersView.render().el)
	}
})
