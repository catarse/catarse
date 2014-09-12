App.views.Project.addChild('ProjectMetrics', {
  el: '#project_metrics',

  activate: function(){
    this.$loader = this.$("#metrics-loading img");
    this.$loaderDiv = this.$("#metrics-loading");
    this.$results = this.$(".results");
    this.path = this.$el.data('path');

    //this.$('.project-metrics').css({width: '980px'});
    //)this.parent.on('selectTab', this.parent.loadTab);
  },

  //loadMetrics: function() {
  //  var that = this;

  //  if($('a#metrics_link').hasClass('selected')) {
  //    $.get(this.path, function(data) {
  //      that.$results.html(data);
  //    });
  //  }
  //}

});

