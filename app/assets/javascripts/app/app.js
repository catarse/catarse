var App = window.App = Skull.View.extend({
  el: 'html',

  events: {
    "click a.my_profile_link" : "toggleMenu"
  },

  beforeActivate: function(){
    this.$search = this.$('#pg_search');
    this.router = new Backbone.Router;
  },

  activate: function(){
    this.$(".best_in_place").best_in_place();
    this.$dropdown = this.$('.dropdown.user');
    this.$flash = this.$('.flash');
    this.flash();
    this.notices();
    Backbone.history.start({pushState: false});
  },

  flash: function() {
    var that = this;
    setTimeout( function(){ that.$flash.slideDown('slow') }, 100)
    if( ! this.$('.flash a').length) setTimeout( function(){ that.$flash.slideUp('slow') }, 16000)
    $(window).click(function(){ that.$('.flash a').slideUp() })
  },

  notices: function() {
    var that = this;
    setTimeout( function(){ this.$('.notice-box').fadeIn('slow') }, 100)
    if(this.$('.notice-box').length) setTimeout( function(){ that.$('.notice-box').fadeOut('slow') }, 16000)
    $('.notice-box a.notice-close').on('click', function(){ that.$('.notice-box').fadeOut('slow') })
  },

  toggleMenu: function(){
    this.$dropdown.slideToggle('slow');
  }
});

$(function(){
  var app = window.app = new App();
});
