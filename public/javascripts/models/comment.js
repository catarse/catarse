var Comment = Backbone.Model.extend()
var Comments = ProjectCollection.extend({
  model: Comment,
  action: "comments",
  controller: "projects"
})
