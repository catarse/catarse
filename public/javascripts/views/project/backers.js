var BackersView = PaginatedView.extend({
	modelView: BackerView,
	emptyTemplate: _.template($('#empty_backers_template').html()),
});
