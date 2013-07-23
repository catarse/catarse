App.addChild('Project', {
  el: '#main_content[data-action="show"][data-controller-name="projects"]',

  events: {
    'click nav#project_menu a' : 'onTabClick',
    'click #toggle_warning a' : 'toggleWarning',
    'click a#embed_link' : 'toggleEmbed'
  },

  activate: function(){
    this.$warning = this.$('#project_warning_text');
    this.$embed= this.$('#project_embed');
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

  loadEmbed: function() {
    var that = this;

    if(this.$embed.find('.loader').length > 0) {
      $.get(this.$embed.data('path')).success(function(data){
        that.$embed.html(data);
      });
    }
  },

  selectTab: function($el){
    this.trigger('onSelectTab');
    this.$('nav#project_menu a').removeClass('selected');
    $el.addClass('selected');
  },

  toggleTab: function($tab){
    this.$('#project_content .content').hide();
    $tab.show();
  },

  onTabClick: function(event){
    var $target = $(event.target);
    var $tab = this.$($target.data('target'));
    this.loadTab($tab);
    this.selectTab($target);
    this.toggleTab($tab);
    return false;
  },

  loadTab: function($tab){
    var that = this;
    if($.trim($tab.html()) == '' && $tab.data('path')){
      $.get($tab.data('path')).success(function(data){
        $tab.html(data);
      });
    }
  },
});

