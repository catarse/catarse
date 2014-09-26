App.addChild('Start', {
  el: '.project-start-wrapper',

  events: {
    "click #learn_link" : "scrollDown"
  },

  scrollDown: function(){
    event.preventDefault();
    $.smoothScroll({
      scrollTarget: '#learn',
      speed: 800
  });
  }
});
