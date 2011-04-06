var Update = Comment.extend({
  defaults: {
    commentable_type: "Project",
    project_update: true
  }
})
var Updates = ProjectCollection.extend({
  model: Update,
  action: "updates",
  controller: "projects"
})
