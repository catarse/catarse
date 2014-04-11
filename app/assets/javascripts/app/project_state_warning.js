App.addChild('ProjectStateWarning', {
  el: '#project-state-warning',

  events: {
    'click .toggle-warning': 'toggleWarning',
    'click .accordion h4': 'toggleAccordion'
  },

  toggleWarning: function(){
      this.$projectWarning.toggleClass('project-warning-hide');
      this.$toggleWarning.toggleClass('open-warning');
      this.$('.accordion-content').toggle;
  },

  toggleAccordion: function(event){
    $(event.target).toggleClass('opened');
    $(event.target).parent().find('.accordion-content').slideToggle("fast");
  },

  activate: function(){
    var that = this;
    this.$projectWarning = this.$('.project-warning');
    this.$toggleWarning = this.$('.toggle-warning');
  }
});

