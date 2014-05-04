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
    }
  },

  startTracking: function(){
    var self = this;
    this.trackPageVisit('projects', 'show', 'Visited project page');
    this.trackPageVisit('explore', 'index', 'Explored projects');
    this.trackPageLoad('contributions', 'show', 'Finished contribution');
    this.trackPageLoad('contributions', 'edit', 'Selected reward');
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

  onLogin: function(){
    mixpanel.alias(this.user.id);
    if(this.user.sign_in_count == 1){
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
    var obj             = $(this);
    var ref             = (obj.attr('href') != undefined) ? obj.attr('href') : null;
    var opt             = options || {};
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
