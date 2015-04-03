App.addChild('Project', _.extend({
  el: 'body[data-action="show"][data-controller-name="projects"]',

  events: {
    'click #toggle_warning a' : 'toggleWarning',
    'click a#embed_link' : 'toggleEmbed'
  },

  activate: function(){
  
    this.$warning = this.$('#project_warning_text');
    this.$embed= this.$('#project_embed');
    this.$container = $(".project-about");
    
    this.route('about');
    this.route('posts');
    this.route('contributions');
    this.route('comments');
    this.route('edit');
    this.route('reports');
    this.route('metrics');
    console.log("setup responsive videos");
    this.setupResponsiveIframes(this.$container);
  
  },

  toggleWarning: function(){
    this.$warning.slideToggle('slow');
    return false;
  },

  toggleEmbed: function(){
    this.loadEmbed();
    this.$embed.slideToggle('slow');
    return false;
  },

  followRoute: function(name){
    var $tab = this.$('nav a[href="' + window.location.hash + '"]');
    if($tab.length > 0){
      this.onTabClick({ currentTarget: $tab });
      var tabs = ['metrics_link'];

      if($.inArray($tab.prop('id'), tabs) !== -1) {
        $('#project-sidebar').hide();
      } else {
        $('#project-sidebar').show();
      }
    }
  },

  loadEmbed: function() {
    var that = this;

    if(this.$embed.is(':empty')) {
      $.get(this.$embed.data('path')).success(function(data){
        that.$embed.html(data);
      });
    }
  }
}, Skull.Tabs, Skull.UI_helper));
