App.addChild('Project', _.extend({
  el: '#main_content[data-action="show"][data-controller-name="projects"]',

  events: {
    'click nav#project_menu a' : 'onTabClick',
    'click #toggle_warning a' : 'toggleWarning',
    'click a#embed_link' : 'toggleEmbed'
  },

  activate: function(){
    this.$warning = this.$('#project_warning_text');
    this.$embed= this.$('#project_embed');
    this.makeRoute('about');
    this.makeRoute('updates');
    this.makeRoute('backers');
    this.makeRoute('comments');
    this.makeRoute('edit');
    this.makeRoute('reports');
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

  //@TODO: Remove this as soon as we migrate to turbolinks
  makeRoute: function(name){
    var that = this;
    var link = name + '_link';
    this.parent.router.route(name, name, function(){
      var $tab = that.$('nav#project_menu a#' + link);
      if($tab.length > 0){
        that.onTabClick({ target: $tab });
      }
    });
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
