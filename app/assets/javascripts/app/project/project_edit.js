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
    'click .dashboard-nav-link-left' : 'toggleNav'
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

  toggleNav: function(){
    if(app.isMobile()){
      app.toggleNav();
    }
  },

  followRoute: function(name){
    var $tab = this.$('nav a[href="' + window.location.hash + '"]');
    var $tab_title = $('#dashboard_' + window.location.hash.split('#')[1]).data('page_title');
    if($tab.length > 0){
      this.onTabClick({ currentTarget: $tab });
    }
    $('#dashboard-page-title').text($tab_title);
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
