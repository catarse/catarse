App.addChild("Registration", {
  el: '#catarse_bootstrap[data-controller-name="registrations"]',

  events: {
    'change input#show_password': 'showPassword'
  },

  showPassword: function(event) {
    return Skull.ShowPasswordInput.togglePass('input#user_password', this.$(event.target).prop('checked'))
  }
});
