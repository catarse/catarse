var ProjectCommentsView = ProjectPaginatedContentView.extend({
  modelView: CommentView,
  events: {
    "click [type=submit]": "createComment",
    "click #show_formatting_tips": "showFormattingTips"
  },
  showFormattingTips: function(event){
    event.preventDefault()
    this.$('#show_formatting_tips').hide()
    this.$('#formatting_tips').slideDown()
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
    comment.save(comment.attributes, {success: this.successCreate, error: this.errorCreate})
  },
  render: function() {
    $(this.el).html(Mustache.to_html(this.template.html(), this.collection))
    this.$('textarea').focus()
    return this
  },
  successCreate: function(model, response){
    this.$('[type=submit]').attr('disabled', false)
    this.$('textarea').val("")
    this.$('textarea').focus()
    var countTag = this.link.find('.count')
    var count = /^\((\d+)\)$/.exec(countTag.html())
    count = parseInt(count[1])
    countTag.html("(" + (count+1) + ")")
    var listItem = $('<li>')
    this.$('#collection_list').prepend(listItem)
    new this.modelView({el: listItem, model: model, contentView: this})
  },
  errorCreate: function(model, response){
    this.$('[type=submit]').attr('disabled', false)
    this.$('textarea').focus()
    alert("Ooops! Ocorreu um erro ao salvar seu comentário. Por favor, tente novamente.")
  }
})
