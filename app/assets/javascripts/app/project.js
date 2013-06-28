App.addChild('Project', {
  el: '#main_content[data-action="show"][data-controller-name="projects"]',

  events: {
    'click nav#project_menu a' : 'onTabClick'
  },

  selectTab: function(selector){
    var $tab = this.$(selector);
  },

  onTabClick: function(event){
    var $target = $(event.target);
    this.loadTab($target.data('target'));
    this.selectTab($target);
    return false;
  },

  loadTab: function(selector){
    var that = this;
    var $tab = this.$(selector);
    if($.trim($tab.html()) == ''){
      $.get($tab.data('path')).success(function(data){
        $tab.html(data);
      });
    }
  },

});

