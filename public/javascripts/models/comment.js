var Comment = Backbone.Model.extend({
  url: function() {
    var base = "/comments";
    if (this.isNew()) return base;
    return base + (base.charAt(base.length - 1) == '/' ? '' : '/') + this.id;
  },
  defaults: {
    commentable_type: "Project",
    project_update: false
  },
  canDestroy: function(){
    if(current_user.get('admin'))
      return true
    if(this.get('user').id == current_user.get('id'))
      return true
    return false
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
