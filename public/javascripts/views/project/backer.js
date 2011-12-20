window.BackerView = Backbone.View.extend({
	tagName: 'li',
	className: "backer",
  template: _.template($('#backer_template').html()),

	initialize: function() {
		_.bindAll(this, 'render');
	},

	render: function() {
		$(this.el).html(this.template(this.model.toJSON()));
		return this;
	}
});

window.BackersView = PaginatedView.extend({
  tagName: 'ul',
	id: 'collection_list',

	initialize: function() {
		_.bindAll(this, 'render');
		this.collection.bind('reset', this.render);
	},

	render: function() {
		var $backers,
				collection = this.collection;
		$backers = $(this.el);

		this.collection.each(function(backer) {
			var view = new BackerView({
				model: backer,
				collection: collection
			});

			$backers.append(view.render().el)
		});
		this.loader.waypoint(this.waypoint, {offset: "100%"});
		return this;
	}
});