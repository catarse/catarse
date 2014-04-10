App.addChild('MixPanel', {
  el: 'body',

  activate: function(){
    this.VISIT_MIN_TIME = 10000;
    this.user = null;
    this.controller = this.$el.data('controller');
    this.action = this.$el.data('action');
    if(window.mixpanel){
      this.startTracking();
    }
  },

  startTracking: function(){
    var self = this;
    this.trackSelectedReward();
    this.trackPageVisit('projects', 'show', 'Visited project page');
    this.trackPageLoad('contributions', 'show', 'Finished contribution');
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

  identifyUser: function(){
    this.user = this.$el.data('user');
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
    var usr             = (this.user != null) ? this.user.id : null;
    var ref             = (obj.attr('href') != undefined) ? obj.attr('href') : null;
    var opt             = options || {};
    var default_options = {
      'page name':  document.title,
      'user_id':    usr,
      'project':    ref,
      'url':        window.location
    };
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
  },

  trackSelectedReward: function(){
    this.mixPanelEvent('input#contribution_submit', 'click', 'Selected reward');
  },
});
