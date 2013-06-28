var App = window.App = Skull.View.extend({
  el: 'html',

  events: {
    "click a.my_profile_link" : "toggleMenu"
  },

  beforeActivate: function(){
    this.$search = this.$('#pg_search');
  },

  activate: function(){
    this.$(".best_in_place").best_in_place();
    this.$dropdown = this.$('.dropdown.user');
    this.$flash = this.$('.flash');
    this.flash();
  },

  toggleMenu: function(){
    this.$dropdown.slideToggle('slow');
  },

  flash: function() {
    var that = this;
    setTimeout( function(){ that.$flash.slideDown('slow') }, 100);
    setTimeout( function(){ that.$flash.slideUp('slow') }, 16000);
  }
});

$(function(){
  var app = window.app = new App();
});
