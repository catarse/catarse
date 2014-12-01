var App = window.App = Skull.View.extend({
  el: 'html',

  events: {
    "click #close-global-alert" : "closeAlert",
    "click a#user-menu" : "toggleMenu",
    "click a.mobile-menu-link" : "mobileMenu",
    "click .zendesk_widget" : "showWidget",
    "click #pg_search_submit" : "searchProject"
  },

  openAlert: function(){
    if(!window.store.get('globalClosed')){
      $('#global-alert').show();
      $('body').css('padding-top', '60px');
      $('#global-alert')
        .css('position', 'fixed')
        .css('margin-top', '-60px')
        .css('width', '100%')
        .css('z-index', '100');
    }
  },

  closeAlert: function(event){
    $('body').css('padding-top', '0');
    $('#global-alert').slideUp('slow');
    window.store.set('globalClosed', true);
  },

  searchProject: function(){
    this.$('#search-form').submit();
    return false;
  },

  beforeActivate: function(){
    this.$search = this.$('#pg_search');
    this.router = new Backbone.Router;
  },

  activate: function(){
    this.openAlert();
    this.$(".best_in_place").best_in_place();
    this.$dropdown = this.$('.dropdown-list.user-menu');
    this.flash();
    this.notices();
    Backbone.history.start({pushState: false});
    this.maskAllElements();
  },

  flash: function() {
    var that = this;
    this.$flash = this.$('.flash');

    setTimeout( function(){ that.$flash.slideDown('slow') }, 100)
    if( ! this.$('.flash a').length) setTimeout( function(){ that.$flash.fadeOut('slow') }, 5000)
    $(window).click(function(){ that.$('.flash a').slideUp() })
  },

  notices: function() {
    var that = this;
    setTimeout( function(){ this.$('.notice-box').fadeIn('slow') }, 100)
    if(this.$('.notice-box').length) setTimeout( function(){ that.$('.notice-box').fadeOut('slow') }, 16000)
    $('.icon-close').on('click', function(){ that.$('.card-notification').fadeOut('slow') })
  },

  maskAllElements: function(){
    this.$('input[data-fixed-mask]').each(function(){
      $(this).fixedMask();
    });
  },

  showWidget: function(){
    Zenbox.show();
    return false;
  },

  toggleMenu: function(){
    this.$dropdown.toggleClass('w--open');
    return false;
  },

});

$(function(){
  var app = window.app = new App();
});
