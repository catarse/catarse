CATARSE.BlogIndexView = Backbone.View.extend({

  initialize: function() {
    _.bindAll(this, "render", "PostView", "PostsView", "initializeView", "platform", "projects", "curated_pages")
    CATARSE.router.route("platform", "platform", this.platform)
    CATARSE.router.route("projects", "projects", this.projects)
    CATARSE.router.route("curated_pages", "curated_pages", this.curated_pages)
    CATARSE.router.route("", "platform", this.platform)
    this.render()
  },

  PostView: CATARSE.ModelView.extend({
    template: _.template(this.$('#post_template').html())
  }),

  PostsView: CATARSE.PaginatedView.extend({
    emptyTemplate: _.template(this.$('#empty_posts_template').html())
  }),

  platform: function(){
    this.selectItem("platform")
    this.initializeView({type: "platform"})
  },

  projects: function(){
    this.selectItem("projects")
    this.initializeView({type: "projects"})
  },

  curated_pages: function(){
    this.selectItem("curated_pages")
    this.initializeView({type: "curated_pages"})
  },

  initializeView: function(search){
    if(this.postsView)
      this.postsView.destroy()
    this.postsView = new this.PostsView({
      modelView: this.PostView,
      collection: new CATARSE.Posts({search: search}),
      loading: this.$("#loading"),
      el: this.$(".blog_posts .results")
    })
  },

  selectItem: function(name) {
    this.selectedItem = $('.section_header a[href=#' + name + ']')
    $('.section_header .selected').removeClass('selected')
    this.selectedItem.addClass('selected')
  }
  
})
