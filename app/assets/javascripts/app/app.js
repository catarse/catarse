var App = window.App = Skull.View.extend({
  el: 'html',

  events: {
    "click a.my_profile_link" : "toggleMenu"
  },

  activate: function(){
    this.$(".best_in_place").best_in_place();
    this.$dropdown = this.$('.dropdown.user');
  },

  toggleMenu: function(){
    this.$dropdown.slideToggle('slow');
  }

});

$(function(){
  var app = window.app = new App();
});
