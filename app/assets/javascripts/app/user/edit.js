App.addChild('UserEdit', _.extend({
  el: '.user-dashboard-edit',

  activate: function(){
    var that = this;

    this.route('contributions');
    this.route('projects');
    this.route('about_me');
    this.route('settings');
    this.route('credit_cards');


    this.nestedLinksSetup();
    this.$('#links').on('cocoon:after-insert', function(e, insertedItem) {
      that.nestedLinksSetup();
    });

    $anchor = this.$('#current_anchor').data('anchor');

    if($anchor != '' && $anchor != undefined) {
      window.location.hash = $anchor;
    } else {
      if(this.$('.dashboard-nav-link.selected').length < 1 && (window.location.hash == '' || window.location.hash == '_#_')) {
        window.location.hash = 'home';
      }
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
  },

  nestedLinksSetup: function() {
    var that = this;
    this.$('a.add-user-link').unbind('click');
    this.$('a.add-user-link').bind('click', function(event) {
      that.$('a.user-links.add_fields').trigger('click');
    });
  }
}, Skull.Tabs));


