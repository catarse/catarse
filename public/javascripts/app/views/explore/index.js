CATARSE.ExploreIndexView = Backbone.View.extend({

  initialize: function() {
    _.bindAll(this, "render", "ProjectView", "ProjectsView", "initializeView", "recommended", "expiring", "recent", "successful", "category", "search", "updateSearch")
    CATARSE.router.route(":name", "category", this.category)
    CATARSE.router.route("recommended", "recommended", this.recommended)
    CATARSE.router.route("expiring", "expiring", this.expiring)
    CATARSE.router.route("recent", "recent", this.recent)
    CATARSE.router.route("successful", "successful", this.successful)
    CATARSE.router.route("search/*search", "search", this.search)
    CATARSE.router.route("", "index", this.index)
    this.render()
    _this = this;
  },

  ProjectView: CATARSE.ModelView.extend({
    template: _.template(this.$('#project_template').html())
  }),

  ProjectsView: CATARSE.PaginatedView.extend({
    emptyTemplate: _.template(this.$('#empty_projects_template').html())
  }),

  search: function(search){
    if(this.$('.section_header .replaced_header')) {
      this.$('.section_header .replaced_header').remove();
    }
    this.$('.section_header .original_title').fadeOut(300, function() {
      $('.section_header').append('<div class="replaced_header"></div>');
      $('.section_header .replaced_header').html('<h1><span>Explore</span> / '+encodeURIComponent(search)+'</h1>');
    })
    this.selectItem("")
    this.initializeView({
      meta_sort: "explore",
      name_or_headline_or_about_or_user_name_or_user_address_city_contains: search
    })
    var input = this.$('#search')
    if(input.val() != search)
      input.val(search)
  },

  updateSearch: function(){
    var search = encodeURIComponent(this.$('#search').val())
    CATARSE.router.navigate("search/" + encodeURIComponent(search), true)
  },

  index: function(){
    _this.changeReplacedTitle()
    _this.selectItem("recommended")
    _this.initializeView({
      recommended: true,
      not_expired: true,
      meta_sort: "explore"
    })
  },

  recommended: function(){
    this.replaceTitleBy("recommended")
    this.selectItem("recommended")
    this.initializeView({
      recommended: true,
      not_expired: true,
      meta_sort: "explore"
    })
  },

  expiring: function(){
    this.replaceTitleBy("expiring")
    this.selectItem("expiring")
    this.initializeView({
      expiring: true,
      meta_sort: "expires_at"
    })
  },

  recent: function(){
    this.replaceTitleBy("recent")
    this.selectItem("recent")
    this.initializeView({
      recent: true,
      not_expired: true,
      meta_sort: "created_at.desc"
    })
  },

  successful: function(){
    this.replaceTitleBy("successful")
    this.selectItem("successful")
    this.initializeView({
      successful: true,
      meta_sort: "expires_at.desc"
    })
  },

  category: function(name){
    this.replaceTitleBy(name)
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

  changeReplacedTitle: function() {
    if(this.$('.section_header .replaced_header')) {
      this.$('.section_header .replaced_header').fadeOut(300, function(){
        $(this).remove();
        $('.section_header .original_title').fadeIn(300);
      });
    }
  },

  replaceTitleBy: function(name) {
    if(this.$('.section_header .replaced_header')) {
      this.$('.section_header .replaced_header').remove();
    }
    this.$('.section_header .original_title').fadeOut(300, function() {
      $('.section_header').append('<div class="replaced_header"></div>');
      $('.section_header .replaced_header').html('<h1><span>Explore</span> '+$('.sidebar a[href=#' + name + ']').text()+'</h1>');
    })
  },

  selectItem: function(name) {
    this.selectedItem = $('.sidebar a[href=#' + name + ']')
    $('.sidebar .selected').removeClass('selected')
    this.selectedItem.addClass('selected')
  },

  render: function(){
    this.$('#header .search input').timedKeyup(this.updateSearch, 1000)
  }

})
