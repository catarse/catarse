App.addChild('MixPanel', {
  el: 'body',

  activate: function(){
    this.VISIT_MIN_TIME = 10000;
    this.user = null;
    this.controller = this.$el.data('controller');
    this.action = this.$el.data('action');
    this.user = this.$el.data('user');
    if(window.mixpanel){
      this.detectLogin();
      this.startTracking();
      this.trackTwitterShare();
      this.trackFacebookShare();
      try {
        this.trackOnFacebookLike();
      } catch(e) {
        console.log(e);
      }
    }
  },

  startTracking: function(){
    var self = this;
    this.trackPageVisit('projects', 'show', 'Visited project page');
    this.trackPageVisit('explore', 'index', 'Explored projects');
    this.trackPageLoad('contributions', 'edit', 'Selected reward');
    this.trackOnPage('contributions', 'show', function(){
      var contribution_data = self.$('.contribution_data')

      self.track('Finished contribution', {
        payment_method: contribution_data.data('payment_method'),
        payment_choice: contribution_data.data('payment_choice')
      });
    });
  },

  trackPageLoad: function(controller, action, text){
    var self = this;
    this.trackOnPage(controller, action, function(){
      self.track(text);
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
      self.track('Share a project', { ref: $(event.currentTarget).data('title'), social_network: 'Twitter' });
    });
  },

  trackFacebookShare: function() {
    var self = this;
    this.$('a#facebook_share').on('click', function(event){
      self.track('Share a project', { ref: $(event.currentTarget).data('title'), social_network: 'Facebook' });
    });
  },

  trackOnFacebookLike: function() {
    var self = this;

    FB.Event.subscribe('edge.create', function(url, html_element){
      self.track('Liked a project', { ref: $(html_element).data('title') });
    });
  },

  onLogin: function(){
    mixpanel.alias(this.user.id);
    if(this.user.created_today){
      this.track("Signed up");
    }
    else{
      this.track("Logged in");
    }
  },

  detectLogin: function(){
    if(this.user){
      if(this.user.id != store.get('user_id')){
        this.onLogin();
        store.set('user_id', this.user.id);
      }
    }
    else{
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
      'project':            ref,
      'url':                window.location
    };
    if(this.user){
      default_options.user_id = this.user.id;
      default_options.created = this.user.created_at;
      default_options.last_login = this.user.last_sign_in_at;
      default_options.contributions = this.user.total_contributed_projects;
      default_options.has_contributions = (this.user.total_contributed_projects > 0);
    }
    var opt     = $.fn.extend(default_options, opt);

    mixpanel.track(text, opt);
  },

  mixPanelEvent: function(target, event, text, options){
    var self = this;
    this.$(target).on(event, function(){
      self.track(text, options);
    });
  },

  trackVisit: function(eventName){
    var self = this;
    window.setTimeout(function(){
      self.track(eventName);
    }, this.VISIT_MIN_TIME);
  }
});
