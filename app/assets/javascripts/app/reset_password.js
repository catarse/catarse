App.addChild("ResetPassword", {
  el: '#catarse_bootstrap[data-controller-name="passwords"]',

  events: {
    'change input#show_password': 'showPassword'
  },

  showPassword: function(event) {
    return Skull.ShowPasswordInput.togglePass(['input#user_password', 'input#user_password_confirmation'], this.$(event.target).prop('checked'))
  }
});
