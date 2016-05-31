App.addChild('Login', {
  el: '#login',

  events: {
    'click .login-fb': 'loginFBClick',
    'submit form': 'formSubmit',
    'change input': 'formFulfill',
    'click #forgot_password': 'forgotClick',
    'click #signup': 'signupClick'
  },

  activate: function() {
  },

  loginFBClick: function() {
    CatarseAnalytics.oneTimeEvent({cat:'account_login',act:'login_fb_link'});
  },

  formSubmit: function() {
    CatarseAnalytics.oneTimeEvent({cat:'account_login',act:'login_form_submit'});
  },

  formFulfill: function() {
    CatarseAnalytics.oneTimeEvent({cat:'account_login',act:'login_data_fulfill'});
  },

  forgotClick: function() {
    CatarseAnalytics.oneTimeEvent({cat:'account_login',act:'login_forgot_pass'});
  },

  signupClick: function() {
    CatarseAnalytics.oneTimeEvent({cat:'account_login',act:'login_signup_link'});
  },

});
App.addChild('Login', {
  el: '#signup',

  events: {
    'click .login-fb': 'loginFBClick',
    'submit form': 'formSubmit',
    'change input': 'formFulfill',
    'click #login': 'loginClick'
  },

  activate: function() {
  },

  loginFBClick: function() {
    CatarseAnalytics.oneTimeEvent({cat:'account_signup',act:'signup_fb_link'});
  },

  formSubmit: function() {
    CatarseAnalytics.oneTimeEvent({cat:'account_signup',act:'signup_form_submit'});
  },

  formFulfill: function() {
    CatarseAnalytics.oneTimeEvent({cat:'account_signup',act:'signup_data_fulfill'});
  },

  loginClick: function() {
    CatarseAnalytics.oneTimeEvent({cat:'account_signup',act:'signup_login_link'});
  },

});
