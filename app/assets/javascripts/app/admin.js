App.addChild('Admin', {
  el: '.admin',

  events: {
    'click .project-admin-menu' : "toggleAdminMenu",
  },

  toggleAdminMenu: function(){
    var link = $(event.target);
    this.$dropdown = link.parent().next('nav');
    $('w--open').not(this.$dropdown).removeClass('w--open');
    this.$dropdown.toggleClass('w--open');
    return false;
  },
});

