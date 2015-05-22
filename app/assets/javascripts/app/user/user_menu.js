App.addChild('UserMenu', {
  el: '.user-menu',

  events: {
    'click a':'closeMenu'
  },

  closeMenu: function(event) {
    this.$el.toggleClass('w--open');
  }
});
