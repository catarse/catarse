App.addChild('UserShow', _.extend({
  el: '.content[data-action="show"][data-controller-name="users"]',

  activate: function(){
    var that = this;

    this.route('contributed');
    this.route('created');
    this.route('about');

    this.lookAnchors();
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

}, Skull.Tabs));



