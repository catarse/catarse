App.addChild('Admin', {
  el: '.admin',

  events: {
    'click .project-admin-menu' : "toggleAdminMenu",
  },

  toggleAdminMenu: function(){
    var link = $(event.target);
    this.$dropdown = link.parent().next('.user-menu');
    $('.user-menu').not(this.$dropdown).removeClass('w--open');
    this.$dropdown.toggleClass('w--open');
    return false;
  },
});

