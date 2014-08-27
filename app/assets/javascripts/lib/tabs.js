Skull.Tabs = {
  selectTab: function($tab, $tabContent){
    $tab.siblings('.selected').removeClass('selected');
    $tab.addClass('selected');
    $tabContent.siblings(':visible').hide();
    $tabContent.show();
    this.trigger('selectTab');
  },

  onTabClick: function(event){
    var $tab = $(event.currentTarget);
    var $tabContent = this.$($tab.data('target'));
    this.loadTab($tabContent);
    this.selectTab($tab, $tabContent);
    return false;
  },

  loadTab: function($tabContent){
    var that = this;

    if($.trim($tabContent.data('path')) != ''){
      $.get($tabContent.data('path')).success(function(data){
        that.$('.results', $tabContent).html(data);
      });
    }
  }
};

