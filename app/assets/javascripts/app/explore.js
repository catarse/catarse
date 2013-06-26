App.addChild('Explore', {
  el: '#main_content[data-action="index"][data-controller-name="explore"]',

  activate: function(){
    this.filter = {
      recommended: true,
      not_expired: true,
      page: 1 
    };
    this.$loader = this.$("#loading img");
    this.$loaderDiv = this.$("#loading");
    this.$results = this.$(".results");
    this.projectsPath = this.$("#explore_results").data('projects-path');
    this.fetchPage();
    this.$window().scroll(this.onScroll);
  },

  fetchPage: function(){
    this.$loader.show();
    $.get(this.projectsPath, this.filter).success(this.onSuccess);
    this.filter.page += 1;
  },

  onSuccess: function(data){
    this.$results.append(data);
    this.$loader.hide();
  },

  $window: function(){
    return $(window);
  },

  isLoaderVisible: function(){
    return this.$window().scrollTop() + this.$window().height() >  this.$loaderDiv.offset().top;
  },

  onScroll: function(event){
    if(this.isLoaderVisible()){
      this.fetchPage();
    }
  }
});
