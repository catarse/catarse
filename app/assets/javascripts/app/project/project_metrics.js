App.views.Project.addChild('ProjectMetrics', {
  el: '#project_metrics',

  activate: function(){
    this.$loader = this.$("#metrics-loading img");
    this.$loaderDiv = this.$("#metrics-loading");
    this.$results = this.$(".results");
    this.path = this.$el.data('path');
  }
});

