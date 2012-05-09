CATARSE.ProjectsShowView = Backbone.View.extend({

  initialize: function() {
    _.bindAll(this, "render", "BackerView", "BackersView", "about", "updates", "backers", "comments", "embed", "isValid", "backWithReward")
    CATARSE.router.route("", "index", this.about)
    CATARSE.router.route("about", "about", this.about)
    CATARSE.router.route("updates", "updates", this.updates)
    CATARSE.router.route("backers", "backers", this.backers)
    CATARSE.router.route("comments", "comments", this.comments)
    CATARSE.router.route("embed", "embed", this.embed)

    this.$('a.destroy_update').live('ajax:beforeSend', function(event, data){
      $(event.target).next('.deleting_update').show();
    });

    this.$('a.destroy_update').live('ajax:success', function(event, data){
      var target = $('.updates_wrapper');
      target.html(data);
      $(event.target).next('.deleting_update').hide();
    });

    this.project = new CATARSE.Project($('#project_description').data("project"))
    this.render()
  },

  events: {
    "click #show_formatting_tips": "showFormattingTips",
    "keyup form input[type=text],textarea": "validate",
    "click #project_link": "selectTarget",
    "click #project_embed textarea": "selectTarget",
    "click #rewards .clickable": "backWithReward"
    //"click #pledge input[type=submit]": "requireLogin"
  },

  UpdatesForm: Backbone.View.extend({
    el: 'form#new_update',
    events: {
      "click #update_submit" : "submit",
      "keyup #project_updates #update_comment" : "validate_comment"
    },

    initialize: function() {
      _.bindAll(this);
      this.loading = this.$('.loading_updates');
    },

    submit: function(){
      this.validate_comment()
      var that = this;
      var form = $(this.el);
      that.loading.show();
      $.post(form.prop('action'), form.serialize(), null, 'html')
        .success(function(data){
          var target = $('.updates_wrapper');
          target.html(data);
          that.loading.hide();
          that.el.reset();
        });
      return false;
    },
    validate_comment: function(el){
      var target = $("#project_updates #update_comment");
      if(target.val() == ''){
        target.addClass('error');
        target.removeClass('ok');
      }else{
        target.removeClass('error');
        target.addClass('ok');
      }
    }
  }),

  BackerView: CATARSE.ModelView.extend({
    template: _.template(this.$('#backer_template').html() || '')
  }),

  BackersView: CATARSE.PaginatedView.extend({
		template: _.template(this.$('#backers_template').html() || ''),
    emptyTemplate: _.template(this.$('#empty_backers_template').html() || '')
  }),

  about: function() {
    this.selectItem("about")
  },

  updates: function() {
    this.selectItem("updates")
    this.updatesForm = new this.UpdatesForm();
    this.$("#project_updates [type=submit]").removeProp('disabled')
  },

  comments: function() {
    this.selectItem("comments")
  },

  backers: function() {
    this.selectItem("backers")
    this.backersView = new this.BackersView({
      modelView: this.BackerView,
      collection: new CATARSE.Backers({url: '/' + CATARSE.locale + '/projects/' + this.project.id + '/backers'}),
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
    window.location.href = url;
    //CATARSE.requireLogin(event, url)
  },
  
  requireLogin: function(event) {
    CATARSE.requireLogin(event)
  }

})
