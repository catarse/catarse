App.views.Project.addChild('ProjectContributions', _.extend({
  el: '#project_contributions',

  activate: function(){
    this.$loader = this.$("#contributions-loading img");
    this.$loaderDiv = this.$("#contributions-loading");
    this.$results = this.$(".results");
    this.path = this.$el.data('path');
    this.filter = {available_to_count: true};
    this.setupScroll();
    this.parent.on('selectTab', this.fetchPage);
  },

  events:{
    "click input[type='radio'][name=contribution_state]": "showContributions"
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

}, Skull.InfiniteScroll));

