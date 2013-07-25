Skull.Tabs = {
  selectTab: function($tab){
    this.trigger('onSelectTab');
    $tab.siblings('.selected').removeClass('selected');
    $tab.addClass('selected');
  },

  toggleTab: function($tabContent){
    $tabContent.siblings(':visible').hide();
    $tabContent.show();
  },

  onTabClick: function(event){
    var $tab = $(event.target);
    var $tabContent = this.$($tab.data('target'));
    this.loadTab($tabContent);
    this.selectTab($tab);
    this.toggleTab($tabContent);
    return false;
  },

  loadTab: function($tabContent){
    var that = this;
    if($.trim($tabContent.html()) == '' && $tabContent.data('path')){
      $.get($tabContent.data('path')).success(function(data){
        $tabContent.html(data);
      });
    }
  }
};

