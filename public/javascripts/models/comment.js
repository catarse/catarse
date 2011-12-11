window.Comments = Backbone.Collection.extend({
	model: Comment,
	url: '/comments'
});

window.Comment = Backbone.Model.extend({
});

// var Comment = Backbone.Model.extend({
//   url: function() {
//     var base = "/comments";
//     if (this.isNew()) return base;
//     return base + (base.charAt(base.length - 1) == '/' ? '' : '/') + this.id;
//   },
//   defaults: {
//     commentable_type: "Project",
//     project_update: false
//   },
//   canDestroy: function(){
//     if(currentUser.get('admin'))
//       return true
//     if(this.get('user').id == currentUser.get('id'))
//       return true
//     return false
//   },
//   toJSON: function(){
//     return {comment: this.attributes}
//   }
// })
// var Comments = ProjectCollection.extend({
//   model: Comment,
//   action: "comments",
//   controller: "projects"
// })
