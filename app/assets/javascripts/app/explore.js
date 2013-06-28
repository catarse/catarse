App.addChild('Explore', {
  el: '#main_content[data-action="index"][data-controller-name="explore"]',

  events: {
    'click a[data-filter]' : 'applyFilter'
  },

  activate: function(){
    this.$loader = this.$("#loading img");
    this.$loaderDiv = this.$("#loading");
    this.$results = this.$(".results");
    this.projectsPath = this.$("#explore_results").data('projects-path');
    this.setInitialFilter();
    this.firstPage();
    this.$window().scroll(this.onScroll);
  },

  setInitialFilter: function(){
    var search = null;;
    if(this.parent && (search = this.parent.$search.val())){
      this.filter = { pg_search: search };
    }
    else{
      this.filter = {
        recommended: true,
        not_expired: true
      };
    }
  },

  firstPage: function(){
    this.EOF = false;
    this.filter.page = 1;
    this.$results.html('');
    this.fetchPage();
  },

  applyFilter: function(e){
    var $target = $(e.target);
    this.filter = $target.data('filter');
    this.firstPage();
    this.$('[data-filter]').removeClass('selected');
    $target.addClass('selected');
    if(this.parent && this.parent.$search.length > 0){
      this.parent.$search.val('');
    }
    return false;
  },

  fetchPage: function(){
    if(!this.EOF){
      this.$loader.show();
      $.get(this.projectsPath, this.filter).success(this.onSuccess);
      this.filter.page += 1;
    }
  },

  onSuccess: function(data){
    if($.trim(data) == ''){
      this.EOF = true;
    }
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
