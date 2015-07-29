App.addChild('ProjectNav', {
  el: '#project-nav',

  events: {
    "click #toggle-edit-menu" : "toggleEdit",
    'click .btn-dashboard' : 'toggleNav',
    'click #info-links' : 'hideEdit',
    'click a.dashboard-nav-link-left' : 'closeNav'
  },

  activate: function() {
    this.setEditState();
  },

  toggleEdit: function(){
    $("#edit-menu-items").slideToggle( "slow" );
  },

  hideEdit: function(){
    $("#edit-menu-items").slideUp('slow');
  },

  toggleNav: function(){
    $(".body-project").toggleClass("closed");
    $(".btn-dashboard").toggleClass("closed fa-cog");
    $(".btn-dashboard").toggleClass("open fa-chevron-left");
    return false;
  },

  setEditState: function(){
    var anchor = window.location.hash.substring(1);
    if(anchor !== '' && $.inArray(anchor, ['home', 'posts', 'reports']) == -1){
      this.toggleEdit();
    }
  },

  closeNav: function(){
    window.scrollTo(0, 0);
    if(app.isMobile()){
      this.toggleNav();
    }
  },

});

