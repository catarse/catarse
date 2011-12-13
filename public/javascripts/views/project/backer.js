window.BackerView = Backbone.View.extend({
  template: _.template($('#backer_template').html())
});

window.BackersView = Backbone.View.extend({
  template: _.template($('#backer_template').html()),

	initialize: function() {
		_.bindAll(this, 'render');
		this.collection.bind('reset', this.render);
	},

	render: function() {
		this.collection.each(function(backer) {
			var view = new BackerView({
				model: backer,
				collection: this.collection
			});
			console.log("back:" + view.model.id)
			$("#project_content").append(view.render().el)
		});
		// $(this.el).html(this.template(this.model.toJSON()));
		return this;
	}
});