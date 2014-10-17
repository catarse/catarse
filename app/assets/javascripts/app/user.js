App.addChild('User', _.extend({
  el: '#main_content[data-action="show"][data-controller-name="users"]',

  //@TODO: Refactor this ugly code into a generic routing generation inside the Skull.Tabs extension
  activate: function(){
    this.route('contributions');
    this.route('projects');
    this.route('credits');
    this.route('settings');
    this.route('unsubscribes');
    this.route('credit_cards');

    this.$('#user_bank_account_attributes_name').brbanks();
  },

  followRoute: function(){
    var $tab = this.$('nav#user_profile_menu a[href="' + window.location.hash + '"]');
    if($tab.length > 0){
      this.onTabClick({ currentTarget: $tab });
    }
  },

}, Skull.Tabs));

