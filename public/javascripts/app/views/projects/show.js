CATARSE.ProjectsShowView = Backbone.View.extend({

  initialize: function() {
    _.bindAll(this, "render", "BackerView", "BackersView", "about", "updates", "backers", "comments", "embed","index", "isValid", "backWithReward")
    CATARSE.router.route("", "index", this.index)
    CATARSE.router.route("about", "about", this.about)
    CATARSE.router.route("updates", "updates", this.updates)
    CATARSE.router.route("backers", "backers", this.backers)
    CATARSE.router.route("comments", "comments", this.comments)
    CATARSE.router.route("embed", "embed", this.embed)
    this.render()
  },

  events: {
    "click #show_formatting_tips": "showFormattingTips",
    "keyup form input[type=text],textarea": "validate",
    "click #project_link": "selectTarget",
    "click #project_embed textarea": "selectTarget",
    "click #rewards .clickable": "backWithReward"
  },

  project: new CATARSE.Project($('#project_description').data("project")),

  BackerView: CATARSE.ModelView.extend({
    template: _.template(this.$('#backer_template').html())
  }),

  BackersView: CATARSE.PaginatedView.extend({
    emptyTemplate: _.template(this.$('#empty_backers_template').html())
  }),

  index: function(){
    this.about()
    CATARSE.router.navigate("about")
  },

  about: function() {
    this.selectItem("about")
  },

  updates: function() {
    this.selectItem("updates")
    this.$("#project_updates [type=submit]").attr('disabled', true)
  },

  comments: function() {
    this.selectItem("comments")
  },

  backers: function() {
    this.selectItem("backers")
    this.backersView = new this.BackersView({
      modelView: this.BackerView,
      collection: this.project.backers,
      loading: this.$("#loading"),
      el: this.$("#project_backers")
    })
  },

  embed: function(){
    this.$('#embed_overlay').show()
    this.$('#project_embed').fadeIn()
  },

  selectItem: function(item) {
    this.$('#project_embed').hide()
    this.$('#embed_overlay').hide()
    this.$('#loading img').hide()
    this.$("#project_content .content").hide()
    this.$("#project_content #project_" + item + ".content").show()
    var link = this.$("#project_menu #" + item + "_link")
    this.$('#project_menu a').removeClass('selected')
    link.addClass('selected')
  },

  showFormattingTips: function(event){
    event.preventDefault()
    this.$('#show_formatting_tips').hide()
    this.$('#formatting_tips').slideDown()
  },

  isValid: function(form){
    var valid = true
    form.find('input[type=text],textarea').each(function(){
      if($(this).parent().hasClass('required') && $.trim($(this).val()) == "") {
        valid = false
      }
    })
    return valid
  },

  validate: function(event){
    var form = $(event.target).parentsUntil('form')
    var submit = form.find('[type=submit]')
    if(this.isValid(form))
      submit.attr('disabled', false)
    else
      submit.attr('disabled', true)
  },

  selectTarget: function(event){
    event.preventDefault()
    $(event.target).select()
  },

  backWithReward: function(event){
    var element = $(event.target)
    if(element.is('a') || element.is('textarea') || element.is('button'))
      return true
    if(!element.is('li'))
      element = element.parentsUntil('li')
    var url = element.find('input[type=hidden]').val()
    if(this.$('#login').length > 0){
      CATARSE.requireLogin(event, url)
    } else {
      window.location.href = url
    }
  },

  render: function(){
    if(this.$('#login').length > 0){
      this.$('#back_project input[type=submit]').click(CATARSE.requireLogin)
    }
  }

})
