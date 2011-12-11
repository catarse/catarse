window.CommentView = Backbone.View.extend({
	tagName: 'li',
	className: 'comment',

	initialize: function() {
		_.bindAll(this, 'render');
		this.model.bind('change', this.render);
		this.template = _.template($('#project_comments_template').html());
	},
	
	render: function () {
		var renderedContent = this.template(this.model.toJSON());
		$(this.el).html(renderedContent);
		return this;
	}

});

window.ProjectCommentsView = CommentView.extend({
	initialize: function() {
		_bindAll(this, 'render');
		this.template = _.template($('#project_comments_template').html());
		this.collection.bind('reset', this.render);
	},
	
	render: function() {
		var $comments,
				collection = this.collection;
		
		$(this.el).html(this.template({}));
		$comments = this.$('.comments');
		collection.each(function(comment) {
			var view = new ProjectCommentsView({
				model: comment,
				collection: collection
			});
			$comments.append(view.render().el);
		});
		return this;
	}
});

// var CommentView = ModelView.extend({
//   template: $('#comment_template')
// })