var Backer = Backbone.Model.extend()
var Backers = ProjectCollection.extend({
  model: Backer,
  action: "backers",
  controller: "projects"
})
