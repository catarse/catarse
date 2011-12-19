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

window.BackersView = Backbone.View.extend({
	id: 'project_backers',
  template: _.template($('#backers_template').html()),

	initialize: function() {
		this.page = 1;
		this.fetched = false;
		_.bindAll(this, 'render');
		this.collection.bind('reset', this.render);
	},

	render: function() {
		if (this.fetched && (this.collection.length == 0)) {
			// render template without backers
		} else {
			var $backers,
					collection = this.collection;
			$(this.el).html(this.template({}));
			$backers = this.$("#collection_list");

			this.collection.each(function(backer) {
				var view = new BackerView({
					model: backer,
					collection: collection
				});

				$backers.append(view.render().el)
			});
			this.fetched = true;
		}
		return this;
	}
});