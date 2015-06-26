App.addChild('ProjectEditForm', _.extend({
  el: '.project-form',

  events: {
    'blur input' : 'checkInput'
  },

  activate: function() {
    this.setupForm();
  },
}, Skull.Form));

App.addChild('ProjectEdit', _.extend({
  el: '.project-dashboard-edit',

  events: {
    'click .btn-dashboard' : 'toggleNav'
  },

  toggleNav: function(){
    $(".body-project").toggleClass("open closed");
    $(".dashboard-nav.side").animate({width: 'toggle'});
    $(".btn-dashboard").toggleClass("open fa fa-lg fa-chevron-left");
    $(".btn-dashboard").toggleClass("closed fa fa-lg fa-cog");
    return false;
  },

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
    this.route('reports');

    if($('.fa-exclamation-circle').length >= 1) {
      window.location.hash = $('.fa-exclamation-circle:eq(0)').parent().attr('href');
    } else {
      this.lookAnchors();
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
