CATARSE.ExploreIndexView = Backbone.View.extend({

  initialize: function() {
    _.bindAll(this, "render", "ProjectView", "ProjectsView", "initializeView", "recommended", "expiring", "recent", "successful", "category")
    CATARSE.router.route(":name", "category", this.category)
    CATARSE.router.route("recommended", "recommended", this.recommended)
    CATARSE.router.route("expiring", "expiring", this.expiring)
    CATARSE.router.route("recent", "recent", this.recent)
    CATARSE.router.route("successful", "successful", this.successful)
    CATARSE.router.route("", "index", this.recommended)
    this.render()
  },

  ProjectView: CATARSE.ModelView.extend({
    template: _.template(this.$('#project_template').html())
  }),

  ProjectsView: CATARSE.PaginatedView.extend({
  	emptyTemplate: _.template(this.$('#empty_projects_template').html())
  }),

  recommended: function(){
    this.selectItem("recommended")
    this.initializeView({
      recommended: true,
      not_expired: true,
      meta_sort: "expires_at"
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
      meta_sort: "created_at.desc"
    })
  },

  initializeView: function(search){
		this.projectsView = new this.ProjectsView({
    	modelView: this.ProjectView,
			collection: new CATARSE.Projects({search: search}),
		  loading: this.$("#loading"),
			el: this.$("#explore_results .results")
		})
  },

  selectItem: function(name) {
    this.selectedItem = $('#explore_menu a[href=#' + name + ']')
    $('#explore_menu .selected').removeClass('selected')
    this.selectedItem.addClass('selected')
  }

})
