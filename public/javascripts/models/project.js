window.Project = Backbone.Model.extend({
	url: '/projects',
	
	initialize: function() {
		this.backers = new Backers;
		this.backers.url = '/projects/' + this.id + '/backers'
	}
})
