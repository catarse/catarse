App.addChild('Guides', _.extend({
  el: '#page-guides',

  activate: function(){
    this.$container = this.$('.w-iframe');

    this.route('starting');
    this.route('you_history');
    this.route('goals');
    this.route('rewards');
    this.route('social');
    this.route('after_project');


    this.setupResponsiveIframes(this.$container);

    if(this.$('.dashboard-nav-link.selected').length < 1 &&  window.location.hash === '') {
      window.location.hash = 'starting';
    }
    
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
}, Skull.Tabs, Skull.UI_helper));


