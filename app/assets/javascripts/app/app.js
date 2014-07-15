var App = window.App = Skull.View.extend({
  el: 'html',

  events: {
    "click a.user-menu" : "toggleMenu",
    "click a.mobile-menu-link" : "mobileMenu",
    "click .zendesk_widget" : "showWidget",
    "click a.icon-feedback-box" : "toggleBox",
  },

  beforeActivate: function(){
    this.$search = this.$('#pg_search');
    this.router = new Backbone.Router;
  },

  activate: function(){
    this.$(".best_in_place").best_in_place();
    this.$dropdown = this.$('.dropdown.user');
    this.flash();
    this.notices();
    this.smoothScroll();
    Backbone.history.start({pushState: false});
    this.$('input[data-mask]').each(this.maskElement);
  },

  flash: function() {
    var that = this;
    this.$flash = this.$('.flash');

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

  maskElement: function(index, el){
    var $el = this.$(el);
    $el.mask($el.data('mask') + '');
  },

  showWidget: function(){
    Zenbox.show();
    return false;
  },

  toggleMenu: function(){
    this.$dropdown.slideToggle('fast');
    return false;
  },

  mobileMenu: function(){
    $(".mobile-menu").slideToggle(500);
  },

  smoothScroll: function() {
    $('a[href*=#]:not([href=#])').click(function() {
      if (location.pathname.replace(/^\//,'') == this.pathname.replace(/^\//,'') && location.hostname == this.hostname) {
        var target = $(this.hash);
        target = target.length ? target : $('[name=' + this.hash.slice(1) +']');
        if (target.length) {
          $('html,body').animate({
            scrollTop: target.offset().top
          }, 1000);
          return false;
        }
      }
    });
  },

  toggleBox: function() {
    this.$(".feedback-box").toggleClass("feedback-box-closed");
    return false;
  },
});

$(function(){
  var app = window.app = new App();
});
