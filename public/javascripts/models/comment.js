var Comment = Backbone.Model.extend({
  url: function(){ return "/comments" },
  defaults: {
    commentable_type: "Project",
    project_update: false
  },
  toJSON: function(){
    return {comment: this.attributes}
  }
})
var Comments = ProjectCollection.extend({
  model: Comment,
  action: "comments",
  controller: "projects"
})
