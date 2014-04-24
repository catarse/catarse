App.addChild('Project', _.extend({
  el: '#catarse_bootstrap[data-action="show"][data-controller-name="projects"]',

  events: {
    'click a#embed_link' : 'toggleEmbed'
  },

  activate: function(){
    this.$embed= this.$('#project_embed');
    this.route('about');
    this.route('updates');
    this.route('contributions');
    this.route('comments');
    this.route('edit');
    this.route('reports');
  },

  toggleEmbed: function(){
    this.loadEmbed();
    this.$embed.slideToggle('fast');
    return false;
  },

  followRoute: function(name){
    var $tab = this.$('.tabs-nav a[href="' + window.location.hash + '"]');
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
