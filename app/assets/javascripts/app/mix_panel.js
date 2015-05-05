App.addChild('MixPanel', {
  el: 'body',

  activate: function(){
    this.VISIT_MIN_TIME = 4000;
    this.user = null;
    this.controller = this.$el.data('controller') || this.$el.data('controller-name');
    this.action = this.$el.data('action');
    this.user = this.$el.data('user');
    this.id = this.$el.data('id');
    if(window.mixpanel){
      this.detectLogin();
      this.startTracking();
    }
  },

  projectProperties: function(){
    return this.$('#project-header').data('stats');
  },

  startTracking: function(){
    var self = this;

    this.trackOnPage('projects', 'show', function(){
      self.trackVisit('Visited project page', self.projectProperties());
      self.trackReminderClick();
      self.trackOnContributionStart();
    });

    this.trackOnPage('projects', 'edit', function(){
      $(window).on('hashchange', function() {
        if(window.location.hash == '#reports'){
          self.track('Project owner engaged with Catarse', _.extend(self.projectProperties(), { action: 'Visited reports' }));
        }
      });
    });

    this.trackOnPage('pages', 'show', function(){ 
      if(self.id == 'start'){
        self.track('Visited start page');
      }
    });
    

    this.trackPageVisit('projects', 'new', 'Visited new project page');
    this.trackPageVisit('projects', 'index', 'Visited home');
    this.trackPageVisit('explore', 'index', 'Explored projects');
    this.trackPageLoad('contributions', 'edit', 'Selected reward');
    this.trackPageLoad('contributions', 'show', 'Finished Contribution')
    this.trackContributions();
    this.trackPaymentChoice();
    this.trackTwitterShare();
    this.trackFacebookShare();
    this.trackFollowCategory();
    try {
      this.trackOnFacebookLike();
      this.trackOnFacebookComment();
    } catch(e) {
      console.log(e);
    }
  },

  trackFollowCategory: function(){
    var self = this;
    this.$('.category-follow .follow-btn').on('click', function(event){
      self.track('Engaged with Catarse', { ref: $(event.currentTarget).data('title'), action: 'click follow category' });
      return true;
    });
  },

  trackOnContributionStart: function(){
    var self = this;

    this.$('.card-reward').on('click', function(event){
      self.trackStartedContribution('Reward click');
    });
    
    this.$('#contribute_project_form').on('click', function(event){
      self.trackStartedContribution('Contribute button click');
    });
  },

  trackStartedContribution: function(action){
    this.track('Started contribution', _.extend(this.projectProperties(), { action: action }));
  },

  trackReminderClick: function(){
    var self = this;
    this.$('#reminder:not([data-method])').on('click', function(event){
      self.track('Engaged with Catarse', { ref: $(event.currentTarget).data('title'), action: 'click reminder' });
      return true;
    });
  },

  trackPageLoad: function(controller, action, text){
    var self = this;
    this.trackOnPage(controller, action, function(){
      self.track(text);
    });
  },

  trackContributions: function(){
    var from = '',
        self = this;
    this.trackOnPage('contributions', 'new', function(){
      if(window.location.href.indexOf('reward_id') > -1){
        from = 'Reward click';  
      } else {
        from = 'Contribute button click';
      }
      self.track('Started contribution', _.extend(self.projectProperties(), {action: from}));
    });
  },

  trackPaymentChoice: function(){
    var self = this;
    this.$('#payment-engines').on('click', '.back-payment-radio-button', function(){
      var choice = $('.back-payment-radio-button:checked').val();
      if(choice === 'slip'){
        self.track('Payment chosen', {payment_choice: 'BoletoBancario'});
      }
      if(choice === 'credit_card'){
        self.track('Payment chosen', {payment_choice: 'CartaoDeCredito'});
      } 
    });
  },

  trackPageVisit: function(controller, action, text){
    var self = this;
    this.trackOnPage(controller, action, function(){
      self.trackVisit(text);
    });
  },

  trackOnPage: function(controller, action, callback){
    if(this.controller == controller && this.action == action){
      callback();
    }
  },

  trackTwitterShare: function() {
    var self = this;

    this.$('#twitter_share_button').on('click', function(event){
      self.track('Engaged with Catarse', { ref: $(event.currentTarget).data('title'), action: 'share twitter' });
    });
  },

  trackFacebookShare: function() {
    var self = this;
    this.$('a#facebook_share').on('click', function(event){
      self.track('Engaged with Catarse', { ref: $(event.currentTarget).data('title'), action: 'share facebook' });
    });
  },

  trackOnFacebookComment: function() {
    var self = this;

    FB.Event.subscribe('comment.create', function(url, html_element){
      self.track('Engaged with Catarse', { ref: $(html_element).data('title'), action: 'comment facebook' });
    });
  },

  trackOnFacebookLike: function() {
    var self = this;

    FB.Event.subscribe('edge.create', function(url, html_element){
      self.track('Engaged with Catarse', { ref: $(html_element).data('title'), action: 'like facebook' });
    });
  },

  onLogin: function(){
    if(this.user.created_today){
      mixpanel.alias(this.user.id);
      this.track("Signed up");
    }
    else{
      this.track("Logged in");
    }
  },

  detectLogin: function(){
    if(this.user){ // User is logged in
      if(this.user.id != store.get('user_id')){ // First page load after login
        this.onLogin();
        store.set('user_id', this.user.id);
      }
    }
    else if(store.get('user_id')){ // Logout
      if(mixpanel && mixpanel.cookie){
        mixpanel.cookie.clear();
      }
      store.set('user_id', null);
    }
  },

  identifyUser: function(){
    if (this.user){
      mixpanel.name_tag(this.user.email);
      mixpanel.identify(this.user.id);
      mixpanel.people.set({
        "$email": this.user.email,
        "$created": this.user.created_at,
        "$last_login": this.user.last_sign_in_at,
        "contributions": this.user.total_contributed_projects
      });
    }
  },

  track: function(text, options){
    this.identifyUser();
    var opt             = options || {};
    var obj             = $(this);
    var ref             = (obj.attr('href') != undefined) ? obj.attr('href') : (opt.ref ? opt.ref : null);
    var default_options = {
      'page name':          document.title,
      'user_id':            null,
      'created':            null,
      'last_login':         null,
      'contributions':      null,
      'has_contributions':  null,
      'projects':           null,
      'has_projects':       null,
      'project':            ref,
      'url':                window.location,
      'host':               window.location.host
    };
    if(this.user){
      default_options.user_id = this.user.id;
      default_options.created = this.user.created_at;
      default_options.last_login = this.user.last_sign_in_at;
      default_options.contributions = this.user.total_contributed_projects;
      default_options.has_contributions = (this.user.total_contributed_projects > 0);
      default_options.projects = this.user.total_created_projects;
      default_options.has_projects = (this.user.total_created_projects > 0);
    }
    var opt     = $.fn.extend(default_options, opt);
    console.log("Will track: "+text);
    console.log(opt);
    mixpanel.track(text, opt);
  },

  mixPanelEvent: function(target, event, text, options){
    var self = this;
    this.$(target).on(event, function(){
      self.track(text, options);
    });
  },

  trackVisit: function(eventName, options){
    var self = this;
    window.setTimeout(function(){
      self.track(eventName, options);
    }, this.VISIT_MIN_TIME);
  }
});
