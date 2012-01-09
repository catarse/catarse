CATARSE.ExploreIndexView = Backbone.View.extend({

  initialize: function() {
    _.bindAll(this, "render", "ProjectView", "ProjectsView", "initializeView", "index", "recommended", "expiring", "recent", "successful", "category", "search", "updateSearch")
    CATARSE.router.route(":name", "category", this.category)
    CATARSE.router.route("recommended", "recommended", this.recommended)
    CATARSE.router.route("expiring", "expiring", this.expiring)
    CATARSE.router.route("recent", "recent", this.recent)
    CATARSE.router.route("successful", "successful", this.successful)
    CATARSE.router.route("search/:search", "all", this.search)
    CATARSE.router.route("", "index", this.index)
    this.render()
  },

  ProjectView: CATARSE.ModelView.extend({
    template: _.template(this.$('#project_template').html())
  }),

  ProjectsView: CATARSE.PaginatedView.extend({
    emptyTemplate: _.template(this.$('#empty_projects_template').html())
  }),

  index: function(){
    this.$("#explore_results .results").html($('#discover_home').html())
  },

  search: function(search){
    search = decodeURIComponent(search)
    this.selectItem("")
    this.initializeView({
      meta_sort: "created_at.desc",
      name_or_headline_or_about_or_user_name_contains: search
    })
    var input = this.$('#search')
    if(input.val() != search)
      input.val(search)
  },

  updateSearch: function(){
    var search = encodeURIComponent(this.$('#search').val())
    this.search(search)
    CATARSE.router.navigate("search/" + search)
  },

  recommended: function(){
    this.selectItem("recommended")
    this.initializeView({
      recommended: true,
      not_expired: true,
      meta_sort: "explore"
    })
  },

  expiring: function(){
    this.selectItem("expiring")
    this.initializeView({
      expiring: true,
      meta_sort: "expires_at"
    })
  },

  recent: function(){
    this.selectItem("recent")
    this.initializeView({
      recent: true,
      not_expired: true,
      meta_sort: "created_at.desc"
    })
  },

  successful: function(){
    this.selectItem("successful")
    this.initializeView({
      successful: true,
      meta_sort: "expires_at.desc"
    })
  },

  category: function(name){
    this.selectItem(name)
    this.initializeView({
      category_id_equals: this.selectedItem.data("id"),
      meta_sort: "explore"
    })
  },

  initializeView: function(search){
    if(this.projectsView)
      this.projectsView.destroy()
    this.projectsView = new this.ProjectsView({
      modelView: this.ProjectView,
      collection: new CATARSE.Projects({search: search}),
      loading: this.$("#loading"),
      el: this.$("#explore_results .results")
    })
  },

  selectItem: function(name) {
    this.selectedItem = $('.sidebar a[href=#' + name + ']')
    $('.sidebar .selected').removeClass('selected')
    this.selectedItem.addClass('selected')
  },

  render: function(){
    this.$('#header .search form').submit(function(){
      return false;
    })
    this.$('#header .search input').timedKeyup(this.updateSearch, 1000)
  }

})
