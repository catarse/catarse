App.addChild('UserEdit', _.extend({
  el: '.user-dashboard-edit',

  events:{
    "click #toggle-notifications": "toggleNotifications"
  },

  activate: function(){

    this.route('contributions');
    this.route('projects');
    this.route('about_me');
    this.route('settings');
    this.route('billing');
    this.route('notifications');
    this.route('feeds');

    this.lookAnchors();

  },

  toggleNotifications: function(event){
    event.preventDefault();
    this.$('#notifications-box').toggle();
  },

  followRoute: function(name){
    var $tab = this.$('nav a[href="' + window.location.hash + '"]');
    if($tab.length > 0){
      this.onTabClick({ currentTarget: $tab });
    }
  },

  loadEmbed: function() {
    var that = this;

    if(this.$embed.find('.loader').length > 0) {
      $.get(this.$embed.data('path')).success(function(data){
        that.$embed.html(data);
      });
    }
  }
}, Skull.Tabs));

App.addChild('UserSettingForm', _.extend({
  el: '#user_form.user-settings-form',

  events: {
    'click #update_email': 'showEmailForm',
    'blur input' : 'checkInput',
    'click input[type="submit"]' : 'customValidate'
  },

  activate: function(){
    this.setupForm();
  },

  showEmailForm: function(){
    this.$('#email_update_form').slideDown();
  },

  customValidate: function(e){
    var $emailIpt = this.$('#new_email'),
        $emailConfirmationIpt = this.$('#new_email_confirmation'),
        email = $emailIpt.val(),
        emailConfirmation = $emailConfirmationIpt.val();

    if (email.trim().length >= 5) {
        if (email !== emailConfirmation) {
            $emailIpt.addClass('error');
            $emailConfirmationIpt.addClass('error');
            return false;
        }
    }

    return this.validate(e);
  }

}, Skull.Form));

App.addChild('UserBillingForm', _.extend({
  el: '#user_billing_form',

  events: {
    'blur input' : 'checkInput',
    'click input[type="submit"]' : 'validate'
  },

  activate: function(){
    this.setupForm();
  }

}, Skull.Form));
