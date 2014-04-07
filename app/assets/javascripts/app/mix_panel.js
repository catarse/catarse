App.addChild('MixPanel', {
  el: 'body',

  activate: function(){
    this.VISIT_MIN_TIME = 10000;
    this.user = null;
    this.contributions = null;
    this.controller = this.$el.data('controller');
    this.action = this.$el.data('action');
    if(window.mixpanel){
      this.startTracking();
    }
  },

  startTracking: function(){
    this.trackSelectedReward();
    if(this.controller == 'projects' && (this.action == 'show' || this.action == 'index')){
      this.trackUserVisit();
    }
    if(this.controller == 'contributions' && this.action == 'show'){
      this.trackOnMixPanel("Visited thank you");
    }
  },

  identifyUser: function(){
    this.user = this.$el.data('user');
    this.contributions = this.$el.data('contributions');
    if (this.user){
      mixpanel.name_tag(this.user.id + '-' + this.user.name);
      mixpanel.identify(this.user.id);
    }
  },

  trackOnMixPanel: function(text, options){
    this.identifyUser();
    var obj             = $(this);
    var usr             = (this.user != null) ? this.user.id : null;
    var created_at      = (this.user != null) ? this.user.created_at : null;
    var contributions   = (this.user != null) ? this.contributions : null;
    var ref             = (obj.attr('href') != undefined) ? obj.attr('href') : null;
    var opt             = options || {};
    var default_options = {
      'page name':  document.title,
      'user_id':    usr,
      'created_at': created_at,
      'contributions': contributions,
      'project':    ref,
      'url':        window.location
    };
    var opt     = $.fn.extend(default_options, opt);

    mixpanel.track(text, opt);
  },

  mixPanelEvent: function(target, event, text, options){
    var self = this;
    this.$(target).on(event, function(){
      self.trackOnMixPanel(text, options);
    });
  },

  trackUserVisit: function(){
    var self = this;
    window.setTimeout(function(){
      self.trackOnMixPanel('Visited home or project page');
    }, this.VISIT_MIN_TIME);
  },

  trackSelectedReward: function(){
    this.mixPanelEvent('input#contribution_submit', 'click', 'Selected reward');
  },
});
