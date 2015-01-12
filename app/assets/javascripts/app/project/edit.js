App.addChild('ProjectEdit', _.extend({
  el: '.content[data-action="edit"][data-controller-name="projects"]',

  activate: function(){
    this.route('basics');
    this.route('home');
    this.route('project');
    this.route('posts');
    this.route('reward');
    this.route('user_about');
    this.route('preview');
    this.route('edit');
    this.route('user_settings');
  },

  followRoute: function(name){
    var $tab = this.$('nav a[href="' + window.location.hash + '"]');
    if($tab.length > 0){
      this.onTabClick({ currentTarget: $tab });
    }
  },

  loadEmbed: function() {
    var that = this;

    if(this.$embed.find('.loader').length > 0) {
      $.get(this.$embed.data('path')).success(function(data){
        that.$embed.html(data);
      });
    }
  }
}, Skull.Tabs));

// FIXME: MORE DRY HERE !!
App.addChild('ProjectSendToAnalysis', _.extend({
  el: '.content[data-action="send_to_analysis"][data-controller-name="projects"]',

  activate: function(){
    this.route('basics');
    this.route('home');
    this.route('project');
    this.route('posts');
    this.route('reward');
    this.route('user_about');
    this.route('preview');
    this.route('edit');
    this.route('user_settings');
  },

  followRoute: function(name){
    var $tab = this.$('nav a[href="' + window.location.hash + '"]');
    if($tab.length > 0){
      this.onTabClick({ currentTarget: $tab });
    }
  },

  loadEmbed: function() {
    var that = this;

    if(this.$embed.find('.loader').length > 0) {
      $.get(this.$embed.data('path')).success(function(data){
        that.$embed.html(data);
      });
    }
  }
}, Skull.Tabs));
