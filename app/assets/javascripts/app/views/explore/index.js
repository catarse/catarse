CATARSE.ExploreIndexView = Backbone.View.extend({

  initialize: function() {
    _.bindAll(this, "render", "near", "ProjectView", "ProjectsView", "initializeView", "recommended", "expiring", "recent", "successful", "category", "search", "updateSearch")
    CATARSE.router.route(":name", "category", this.category)
    CATARSE.router.route("near", "near", this.near)
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
    template: function(){
      return $('#project_template').html()
    }
  }),

  ProjectsView: CATARSE.PaginatedView.extend({
    template: function(){
      return $('#projects_template').html()
    },
    emptyTemplate: function(){
      return $('#empty_projects_template').html()
    }
  }),

  search: function(search){
    search = decodeURIComponent(search);
    if(this.$('.section_header .replaced_header')) {
      this.$('.section_header .replaced_header').remove();
    }
    this.$('.section_header .original_title').fadeOut(300, function() {
      $('.section_header').append('<div class="replaced_header"></div>');
      $('.section_header .replaced_header').html('<h1><span>Explore</span> / '+ search +'</h1>');
    })
    this.selectItem("")
    this.initializeView({
      pg_search: search
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
      not_expired: true
    })
  },

  near: function() {
    this.replaceTitleBy("near")
    this.selectItem("near")
    this.initializeView({
      near_of: $('#nearOfData').data('state')
    })
  },

  recommended: function(){
    this.replaceTitleBy("recommended")
    this.selectItem("recommended")
    this.initializeView({
      recommended: true,
      not_expired: true
    })
  },

  expiring: function(){
    this.replaceTitleBy("expiring")
    this.selectItem("expiring")
    this.initializeView({
      expiring: true
    })
  },

  recent: function(){
    this.replaceTitleBy("recent")
    this.selectItem("recent")
    this.initializeView({
      recent: true,
      not_expired: true
    })
  },

  successful: function(){
    this.replaceTitleBy("successful")
    this.selectItem("successful")
    this.initializeView({
      successful: true
    })
  },

  category: function(name){
    this.replaceTitleBy(name)
    this.selectItem(name)
    this.initializeView({
      by_category_id: this.selectedItem.data("id")
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
