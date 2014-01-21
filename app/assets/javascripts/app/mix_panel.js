App.addChild('MixPanel', {
  el: 'body',

  activate: function(){
    this.user = null;
    this.trackUserClickOnProjectsImage();
    this.trackUserClickOnProjectsTitle();
    this.trackUserClickOnContributeButton();
    this.trackUserClickOnReviewAndMakePayment();
    this.trackUserClickOnAcceptTerms();
    this.trackUserClickOnPaymentButton();
    this.trackUserClickOnReward();
  },

  identifyUser: function(){
    this.user = this.$el.data('user');
    if (this.user){
      mixpanel.name_tag(this.user.id + '-' + this.user.name);
      mixpanel.identify(this.user.id);
    }
  },

  trackOnMixPanel: function(target, event, text, options){
    var self = this;
    this.$(target).on(event, function(){
      self.identifyUser();
      var obj     = $(this);
      var usr     = (self.user != null) ? self.user.id : null;
      var ref     = (obj.attr('href') != undefined) ? obj.attr('href') : null;
      var opt     = options || {};
      var default_options = {
        'page name':  document.title,
        'user_id':    usr,
        'project':    ref,
        'url':        window.location
      };
      var opt     = $.fn.extend(default_options, opt);

      mixpanel.track(text, opt);
    });
  },

  trackUserClickOnReward: function(){
    this.trackOnMixPanel('#rewards .clickable', 'click', 'Clicked on a reward');
    this.trackOnMixPanel('#rewards .clickable_owner span.avaliable', 'click', 'Clicked on a reward');
  },

  trackUserClickOnReviewAndMakePayment: function(){
    this.trackOnMixPanel('input#contribution_submit', 'click', 'Clicked on Review and Make Payment');
  },

  trackUserClickOnAcceptTerms: function(){
    this.trackOnMixPanel('label[for="accept"]', 'click', 'Accepted terms of use');
  },

  trackUserClickOnPaymentButton: function(){
    this.trackOnMixPanel('form.moip input[type="submit"]', 'click', 'Made a payment')
  },

  trackUserClickOnContributeButton: function(){
    this.trackOnMixPanel('#contribute_project_form input', 'click', 'Clicked on Contribute this project');
  },

  trackUserClickOnProjectsImage: function(){
    this.trackOnMixPanel('.box .cover a', 'click', 'Clicked on a projects image @ homepage');
  },

  trackUserClickOnProjectsTitle: function(){
    this.trackOnMixPanel('.project_content h4','click', 'Clicked on a project\'s link box');
  }
});
