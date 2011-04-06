var ProjectCommentsView = ProjectPaginatedContentView.extend({
  collectionView: CommentsView,
  modelView: CommentView,
  events: {
    "click [type=submit]": "createComment"
  },
  createComment: function(event){
    event.preventDefault()
    var text = $.trim(this.$('textarea').val())
    if(!text)
      return
    this.$('[type=submit]').attr('disabled', true)
    var comment = new this.collection.model({
      commentable_id: this.collection.project.get('id'),
      comment: text
    })
    comment.save(comment.attributes, {success: this.success, error: this.error})
  },
  success: function(model, response){
    this.$('[type=submit]').attr('disabled', false)
    this.$('textarea').val("")
    this.$('textarea').focus()
    new this.modelView({el: this.$('ul'), model: model})
  },
  error: function(model, response){
    this.$('[type=submit]').attr('disabled', false)
    this.$('textarea').focus()
    alert("Ooops! Ocorreu um erro ao salvar seu comentário. Por favor, tente novamente.")
  }
})
