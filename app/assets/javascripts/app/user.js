App.addChild('User', _.extend({
  el: '#main_content[data-action="show"][data-controller-name="users"]',

  events: {
    'click nav#user_profile_menu a' : 'onTabClick'
  }
}, Skull.Tabs));

