App.addChild("Registration", {
  el: '#catarse_bootstrap[data-controller-name="registrations"]',

  events: {
    'change input#show_password': 'showPassword'
  },

  activate: function() {
    this.$password_input = this.$('input#user_password');
  },

  showPassword: function(event) {
    var $show_password = this.$(event.target);

    if($show_password.prop('checked')) {
      this.$password_input.prop('type', 'text');
    } else {
      this.$password_input.prop('type', 'password');
    }

    return false;
  }
});
