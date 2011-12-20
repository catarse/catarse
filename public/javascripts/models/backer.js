window.Backer = Backbone.Model.extend({
	url: '/backers'
});

window.Backers = PaginatedCollection.extend({
  model: Backer,
  action: "backers",
  controller: "projects"
});
