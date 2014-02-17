App.addChild('HowItWorks', {
  el: '.how-it-works-wrapper',

  activate: function(){
    this.body = this.$('.how-it-works');
    this.sidebar = this.$('.how-it-works-sidebar');
    this.sidebar.sticky({topSpacing:0});
    this.$('#side-menu').append(this.generateMenu());
  },

  generateMenu: function(){
    return _.map(this.getHeaders(), function(el){ 
      return $('<li>').append($('<a>').prop('href', '#' + el.prop('id')).html(el.html()));
    });
  },

  getHeaders: function(){
    return this.body.find('h3').map(function(i, el){
      return $(el).prop('id', 'topic_' + i);
    });
  }
});



