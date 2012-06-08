CATARSE.UsersShowView = Backbone.View.extend({

  initialize: function() {
    _.bindAll(this, "index", "backs", "projects", "credits", "comments", "request_refund", 'settings', 'closeCreditsModal')
    CATARSE.router.route("", "index", this.index)
    CATARSE.router.route("backs", "backs", this.backs)
    CATARSE.router.route("projects", "projects", this.projects)
    CATARSE.router.route("credits", "credits", this.credits)
    CATARSE.router.route("comments", "comments", this.comments)
    CATARSE.router.route("settings", "settings", this.settings)
    CATARSE.router.route("request_refund/:back_id", "request_refund", this.request_refund)
    this.user = new CATARSE.User($('#user_profile').data("user"))
    this.render()

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

    $('input[type=checkbox]').click(function(){
      $.post('/users/update_attribute_on_the_spot', {
        id: 'user__' + $(this).attr('id') + '__' + $('#id').val(),
        value: ($(this).is(':checked') ? 1 : null)
      })
    })
  },

  events: {
    'click #creditsModal .modal-footer a':'closeCreditsModal',
  },

  closeCreditsModal: function(e) {
    e.preventDefault();
    this.$('#creditsModal').modal('hide');
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

  comments: function() {
    this.selectItem("comments")
  },

  request_refund: function(back_id) {
    url = '/users/'+this.user.id+'/request_refund/'+back_id;
    $.post(url, function(result) {
      //alert(result['status']);
      //notificationHtml = '<div class="bootstrap-alert with_small_font">';
        //notificationHtml += '<div class="alert alert-block">';
        //notificationHtml += '<a class="closeAlert" data-dismiss="alert">×</a>';
        //notificationHtml += result['status'];
        //notificationHtml += '</div>';
      //notificationHtml +='</div>';
      $('#creditsModal .modal-body').html(result['status']);
      $('#current_credits').html(result['credits']);
      $('#creditsModal').modal({
        backdrop: true,
      })

      //console.log($('.table_title').append(notificationHtml));

      $("tr#back_"+back_id+" td.status").text(result['status'])
    })
  },

  selectItem: function(item) {
    this.$("#user_profile_content .content").hide()
    this.$("#user_profile_content #user_" + item + ".content").show()
    var link = this.$("#user_profile_menu #" + item + "_link")
    link.parent().children().removeClass('selected')
    link.addClass('selected')
  }

})
