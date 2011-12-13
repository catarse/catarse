window.Backer = Backbone.Model.extend({
	url: '/backers'
});

window.Backers = Backbone.Collection.extend({
  model: Backer,
  action: "backers",
  controller: "projects"
});
