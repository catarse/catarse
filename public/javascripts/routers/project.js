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
		this.aboutView.container = $("#project_content #about_tab");
		this.project = project;
		
		this.backersView = new BackersView({
			collection: this.project.backers,
			loader: $("#loading")
		});
		this.backersView.container = $("#project_content #backers_tab");

		this.selectItem("about_tab");
	},
	
	about: function() {
		this.aboutView.container.append(this.aboutView.render().el);
	},

	backers: function() {
		this.selectItem("backers_tab");
		this.backersView.collection.fetch();
		this.backersView.container.append(this.backersView.render().el)
	},
	
	selectItem: function(item) {
		$("#project_content .content").hide();
		$("#project_content #"+item+".content").show();
	}
})
