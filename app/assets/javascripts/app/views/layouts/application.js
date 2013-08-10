CATARSE.LayoutsApplicationView = Backbone.View.extend({

  initialize: function() {
    this.dropDownOpened = false;
    _.bindAll(this, "render", "notices", "flash", "currentUserDropDown")
    this.render();
  },

  events: {
    "submit .search": "search",
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

  search: function(event) {
    var query = this.$(event.target).find("#search").val()
    if(!($('#main_content').data("controller-name") == "explore" && $('#main_content').data("action") == "index") && query.length > 0)
      location.href = "/explore#search/" + query
    return false
  },

  flash: function() {
    setTimeout( function(){ this.$('.flash').slideDown('slow') }, 100)
    if( ! this.$('.flash a').length) setTimeout( function(){ this.$('.flash').slideUp('slow') }, 16000)
    $(window).click(function(){ this.$('.flash a').slideUp() })
  },

  notices: function() {
    var that = this;
    setTimeout( function(){ this.$('.notice-box').fadeIn('slow') }, 100)
    if(this.$('.notice-box').length) setTimeout( function(){ that.$('.notice-box').fadeOut('slow') }, 16000)
    $('.notice-box a.notice-close').on('click', function(){ that.$('.notice-box').fadeOut('slow') })
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

  render: function(){
    this.flash()
    this.notices()
  }

})
