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
	className: 'collection_list',
	modelView: BackerView
});