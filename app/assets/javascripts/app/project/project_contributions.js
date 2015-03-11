App.views.Project.addChild('ProjectContributions', _.extend({
  el: '#project_contributions',

  activate: function(){
    
    this.filter = {available_to_count: true};
    this.setupPagination(
      this.$("#contributions-loading img"),
      this.$("#load-more"),
      this.$(".results"),
      this.$el.data('path')
    );
    this.parent.on('selectTab', this.fetchPage);
  },

  events:{
    "click input[type='radio'][name=contribution_state]": "showContributions",
    "click #load-more" : "loadMore"
  },

  showContributions: function(){
    var state = $('input:radio[name=contribution_state]:checked').val();
    if(state == 'waiting_confirmation'){
      this.filter = {with_state: 'waiting_confirmation'};
    }
    else{
      this.filter = {available_to_count: true};
    }
    this.firstPage();
    this.fetchPage();
  }

}, Skull.Pagination));

