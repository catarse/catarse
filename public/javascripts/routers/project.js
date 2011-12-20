window.ProjectPage = Backbone.Router.extend({
	routes: {
		'': 'about',
		'about': 'about',
		'updates': 'updates',
		'backers': 'backers',
		'backers/:page': 'backers',
		'comments': 'comments'
	},
	
	initialize: function() {
		this.aboutView = new ProjectAboutView({});
		this.aboutView.container = $("#project_content #about");
		this.project = project;
		
		this.backersView = new BackersView({
			collection: this.project.backers,
		});
		this.backersView.container = $("#project_content #backers")

		this.selectItem("about");
	},
	
	about: function() {
		this.aboutView.container.append(this.aboutView.render().el);
	},

	backers: function() {
		this.selectItem("backers");
		this.backersView.collection.fetch();
		this.backersView.loader = $("#loading");
		this.backersView.container.append(this.backersView.render().el)
	},
	
	selectItem: function(item) {
		$("#project_content .content").hide();
		$("#project_content #"+item+".content").show();
	}
})
