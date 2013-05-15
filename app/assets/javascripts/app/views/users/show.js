CATARSE.UsersShowView = Backbone.View.extend({

  initialize: function() {
    _.bindAll(this, "index", "backs", "projects", "credits", "comments", 'settings', 'unsubscribes')
    CATARSE.router.route("", "index", this.index)
    CATARSE.router.route("backs", "backs", this.backs)
    CATARSE.router.route("projects", "projects", this.projects)
    CATARSE.router.route("credits", "credits", this.credits)
    CATARSE.router.route("comments", "comments", this.comments)
    CATARSE.router.route("settings", "settings", this.settings)
    CATARSE.router.route("unsubscribes", "unsubscribes", this.unsubscribes)
    this.user = new CATARSE.User($('#user_profile').data("user"))
    this.render()
    this.toggleProjects();

    $('input,textarea').live('keypress', function(e){
      if (e.which == '13' && $("button:contains('OK')").attr('disabled')) {
        e.preventDefault();
      }
    })

    $('#user_feed input').live('keyup', function(){
      var value = $(this).val()
      var re = /^[a-z0-9\._-]+@([a-z0-9][a-z0-9-_]*[a-z0-9-_]\.)+([a-z-_]+\.)?([a-z-_]+)$/
      if(value.match(re)){
        $(this).addClass("ok").removeClass("error")
        $("button:contains('OK')").attr('disabled', false)
      } else {
        $(this).addClass("error").removeClass("ok")
        $("button:contains('OK')").attr('disabled', true)
      }
    })

  },

  events: {
    'change #subscribed_check':'toggleProjects',
    'click .subscribed_projects li label input':'toggleCheckboxes',
  },

  toggleCheckboxes: function(e) {
    return this.$("#subscribed_check li label input").prop('checked')
  },

  toggleProjects: function(e) {
    checked = this.toggleCheckboxes()
    checked ? this.$(".subscribed_projects li label").removeClass('disabled') :
      this.$(".subscribed_projects li label").addClass('disabled')
  },

  BackView: CATARSE.ModelView.extend({
    template: function(){
      return $('#user_back_template').html()
    }
  }),

  BacksView: CATARSE.PaginatedView.extend({
    template: function(){
      return $('#user_backs_template').html()
    },
    emptyTemplate: function(){
      return $('#empty_user_back_template').html()
    },
    afterUpdate: function() {
      FB.XFBML.parse()
    }
  }),

  ProjectView: CATARSE.ModelView.extend({
    template: function(){
      return $('#user_project_template').html()
    }
  }),

  ProjectsView: CATARSE.PaginatedView.extend({
    template: function(){
      return $('#user_projects_template').html()
    },
    emptyTemplate: function(){
      return $('#empty_user_project_template').html()
    },
    afterUpdate: function() {
      FB.XFBML.parse()
    }
  }),

  index: function() {
    CATARSE.router.navigate("backs", {trigger: true})
  },

  backs: function() {
    if(this.backsView)
      this.backsView.destroy()
    this.selectItem("backed_projects")
    this.backsView = new this.BacksView({
      modelView: this.BackView,
      collection: this.user.backs,
      loading: this.$("#loading"),
      el: this.$("#user_backed_projects")
    })
  },

  projects: function() {
    if(this.projectsView)
      this.projectsView.destroy()
    this.selectItem("created_projects")
    this.projectsView = new this.ProjectsView({
      modelView: this.ProjectView,
      collection: this.user.projects,
      loading: this.$("#loading"),
      el: this.$("#user_created_projects")
    })
  },

  credits: function() {
    this.selectItem("credits")
    this.$("#loading").children().hide();
  },

  settings: function() {
    this.selectItem("settings")
    this.$("#loading").children().hide();
  },

  unsubscribes: function() {
    this.selectItem("unsubscribes")
    this.$("#loading").children().hide();
  },

  comments: function() {
    this.selectItem("comments")
  },

  selectItem: function(item) {
    this.$("#user_profile_content .content").hide()
    this.$("#user_profile_content #user_" + item + ".content").show()
    var link = this.$("#user_profile_menu #" + item + "_link")
    link.parent().children().removeClass('selected')
    link.addClass('selected')
  }

})
