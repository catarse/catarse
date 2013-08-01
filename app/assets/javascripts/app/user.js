App.addChild('User', _.extend({
  el: '#main_content[data-action="show"][data-controller-name="users"]',

  events: {
    'click nav#user_profile_menu a' : 'onTabClick'
  },

  activate: function(){
    this.makeRoute('backs');
    this.makeRoute('projects');
    this.makeRoute('credits');
    this.makeRoute('settings');
    this.makeRoute('unsubscribes');
  },

  makeRoute: function(name){
    var that = this;
    this.parent.router.route(name, name, function(){
      var $tab = that.$('nav#user_profile_menu a[href="#' + name + '"]');
      if($tab.length > 0){
        that.onTabClick({ target: $tab });
      }
    });
  },

}, Skull.Tabs));

