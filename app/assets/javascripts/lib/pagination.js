Skull.Pagination = {
  setupPagination: function(){
    this.EOF = false;
    this.filter.page = 1;
    this.$results.html('');

  },

  fetchPage: function(){
    this.$loader.show();
    $.get(this.path, this.filter).success(this.onSuccess);
    this.filter.page += 1;
  },

  onSuccess: function(data){
    if($.trim(data) == ''){
      this.EOF = true;
    }
    this.$results.append(data);
    this.$loader.toggle();
    this.trigger('load:success', data);
  },

  loadMore: function(event){
    // the isLoaderDivVisible check if the div is already in the view pane to load more content
    // the $loader.is(:visible) is here to avoid trigerring two concurrent fetchPage calls
    event.preventDefault();

    if(!this.EOF){
      this.fetchPage();
    }
    
  }
};
