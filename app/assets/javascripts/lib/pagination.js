Skull.Pagination = {
  setupPagination: function($loader, $loadMore, $results, path){
    this.EOF = false;
    this.filter.page = 1;
    this.path = path;
    this.$loader = $loader;
    this.$loadMore = $loadMore;
    this.$results = $results;
    this.$results.empty();
  },

  getPath: function(){
    return $.get(this.path, this.filter);
  },

  onLastPage: function(){

    var that = this;
    
    this.getPath().success(function(data){
      if($.trim(data) !== ''){
       that.$loadMore.show();
      }
    });

  },

  fetchPage: function(){
    this.$loader.show();
    this.$loadMore.hide();
    this.getPath().success(this.onSuccess);
  },

  onSuccess: function(data){
    this.filter.page += 1;
    this.onLastPage();
    this.$results.append(data);
    this.$loader.toggle();
    this.trigger('load:success', data);
  },

  loadMore: function(event){
    
    event.preventDefault();

    if(!this.EOF){
      this.fetchPage();
    }

  }
};