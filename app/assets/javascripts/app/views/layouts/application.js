CATARSE.LayoutsApplicationView = Backbone.View.extend({

  initialize: function() {
    this.dropDownOpened = false;
    _.bindAll(this, "render", "flash", "openLogin", "closeLogin", "submitLogin", "currentUserDropDown")
    CATARSE.router.route("login/*url", "login_with_url", this.openLogin)
    CATARSE.router.route("login", "login", this.openLogin)
    this.render()
  },

  events: {
    "submit .search": "search",
    "click #login .close": "closeLogin",
    "click #login a.provider": "submitLogin",
    "click a.my_profile_link":"currentUserDropDown",
    "focus .form_login.bootstrap-form input":"markLoginForm",
    "focus .form_register.bootstrap-form input":"markRegisterForm",
  },

  markRegisterForm: function(e){
    rootElement = $(e.currentTarget).closest('.bootstrap-form')
    if(!rootElement.hasClass('actived')) {
      $('.bootstrap-form').removeClass('actived');
      rootElement.addClass('actived');
    }
  },

  markLoginForm: function(e){
    rootElement = $(e.currentTarget).closest('.bootstrap-form')
    if(!rootElement.hasClass('actived')) {
      $('.bootstrap-form').removeClass('actived');
      rootElement.addClass('actived');
    }
  },
  
  openLogin: function(returnUrl) {
    var url = null
    if(typeof(returnUrl) != 'undefined')
      url = returnUrl
    else
      url = CATARSE.router.lastPath()
    this.$('#login #return_to').val(url)
    this.$('#login_overlay').show()
    this.$('#login').fadeIn()
  },
  
  closeLogin: function(event) {
    this.$('#login #return_to').val(null)
    this.$('#login').hide()
    this.$('#login_overlay').hide()
  },

  submitLogin: function(event) {
    event.preventDefault()
    var element = $(event.target)
    if(!element.is('a'))
      element = element.parent()
    if(element.hasClass('disabled'))
      return false
    this.$('#login a.provider').addClass('disabled')
    this.$('#login #provider').val(element.attr('href'))
    this.$('#login form').submit()
  },
  
  search: function(event) {
    var query = this.$(event.target).find("#search").val()
    if(!($('#main_content').data("controller-name") == "explore" && $('#main_content').data("action") == "index") && query.length > 0)
      location.href = "/explore#search/" + query
    return false
  },
  
  flash: function() {
    setTimeout( function(){ this.$('.flash').slideDown('slow') }, 100)
    if( ! this.$('.flash a').length) setTimeout( function(){ this.$('.flash').slideUp('slow') }, 16000)
    $(window).click(function(){ this.$('.flash').slideUp() })
  },

  currentUserDropDown: function(e) {
    e.preventDefault();
    $dropdown = this.$('.dropdown.user');
    if(!this.dropDownOpened) {
      $dropdown.show();
      this.dropDownOpened = true;
    } else {
      this.dropDownOpened = false;
      $dropdown.hide();
    }

  },

  newsletterModal: function() {
    $('#newsletterModal').modal();
  },

  render: function(){
    this.flash()
    this.newsletterModal()
  }

})
