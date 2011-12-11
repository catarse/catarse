window.ProjectAboutView = Backbone.View.extend({

	initialize: function() {
		_.bindAll(this, 'render');
		this.template = _.template($("#project_about_template").html());
	},

	render: function () {
		$(this.el).html(this.template);
		return this;
	}

});
