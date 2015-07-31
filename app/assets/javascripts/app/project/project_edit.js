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

  activate: function(){
    this.route('basics');
    this.route('goal');
    this.route('description');
    this.route('budget');
    this.route('card');
    this.route('home');
    this.route('video');
    this.route('posts');
    this.route('reward');
    this.route('user_about');
    this.route('preview');
    this.route('analysis_success');
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
    var $tab_title = $('#dashboard_' + window.location.hash.split('#')[1]).data('page_title');
    var $tab_subtitle = $('#dashboard_' + window.location.hash.split('#')[1]).data('page_subtitle');
    if($tab.length > 0){
      this.onTabClick({ currentTarget: $tab });
    }
    $('#dashboard-page-title').text($tab_title);
    $('#dashboard-page-subtitle').text($tab_subtitle);
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
