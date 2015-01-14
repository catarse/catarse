App.addChild('ProjectEdit', _.extend({
  el: '.project-dashboard-edit',

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
    this.route('reports')

    if(this.$('.dashboard-nav-link.selected').length < 1 &&  window.location.hash == '') {
      window.location.hash = 'home'
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
}, Skull.Tabs));
