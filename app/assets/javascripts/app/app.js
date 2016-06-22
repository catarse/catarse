var App = window.App = Skull.View.extend({
  el: 'html',

  events: {
    "click #close-global-alert" : "closeAlert",
    "click a#user-menu" : "toggleMenu",
    "click a.mobile-menu-link" : "mobileMenu",
    "click .zendesk_widget" : "showWidget",
    "click #pg_search_submit" : "searchProject",
    "click #header_login_btn": "header_login_btnClick"
  },

  header_login_btnClick: function() {
    CatarseAnalytics.oneTimeEvent({cat:'account_login',act:'login_headerbtn_click'});
  },

  openAlert: function(){
    if($('#global-alert').length === 0 || this.$('body').data('mobile')){
      return;
    }
    if($('#fixed-alert').length > 0 && !this.$('body').data('mobile')){
      $('#fixed-alert').addClass('fixed-alert-visible');
      $('.main-header, .hero-search').addClass('with-fixed-alert');
      this.fixedAlert = true;
    }
    if(!window.store.get('newGlobalClosedStore')){
      $('#global-alert').slideDown(400);
      $('.main-header').addClass('with-global-alert');
      if(this.fixedAlert){
        $('.main-header, #global-alert').addClass('with-two-alerts');
      }
    }

  },

  closeAlert: function(event){
    $('#global-alert').slideUp(400);
    $('.main-header').removeClass('with-global-alert').removeClass('with-two-alerts');
    window.store.set('newGlobalClosedStore', true);
    this.globalAlert = false;
  },

  searchProject: function(){
    this.$('.discover-form:visible').submit();
    return false;
  },

  beforeActivate: function(){
    this.$search = this.$('#pg_search');
    this.router = new Backbone.Router();
  },

  activate: function(){
    this.openAlert();
    this.$(".best_in_place").best_in_place();
    this.$dropdown = this.$('.dropdown-list.user-menu');
    this.flash();
    this.notices();
    Backbone.history.start({pushState: false});
    this.maskAllElements();
    this.applyErrors();
    window.CatarseMixpanel.activate();
  },

  flash: function() {
    var that = this;
    this.$flash = this.$('.flash');

    setTimeout( function(){ that.$flash.slideDown('slow'); }, 100);
    if( ! this.$('.flash a').length) setTimeout( function(){ that.$flash.fadeOut('slow'); }, 5000);
    $(window).click(function(){ that.$('.flash a').slideUp(); });
  },

  notices: function() {
    var that = this;
    setTimeout( function(){ this.$('.notice-box').fadeIn('slow'); }, 100);
    if(this.$('.notice-box').length) setTimeout( function(){ that.$('.notice-box').fadeOut('slow'); }, 16000);
    $('.icon-close').on('click', function(){ that.$('.card-notification').fadeOut('slow'); });

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

  applyErrors: function(){
    $.each($('[data-applyerror=true]'), function(i, item){
      $(item).addClass('error');
    });
  },

  isMobile: function(){
    var isMobile = /Android|webOS|iPhone|iPad|iPod|BlackBerry|IEMobile|Opera Mini/i.test(navigator.userAgent);
    return isMobile;
  }

});

$(function(){
  var app = window.app = new App();
  window.toggleMenu = app.toggleMenu;
});
