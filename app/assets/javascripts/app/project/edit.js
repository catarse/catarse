App.addChild('ProjectEdit', _.extend({
  el: '.content[data-action="edit"][data-controller-name="projects"]',

  activate: function(){
    this.route('basics');
    this.route('dashboard_project');
    this.route('dashboard_reward');
    this.route('edit');
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

