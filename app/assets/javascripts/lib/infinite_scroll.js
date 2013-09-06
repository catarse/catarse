Skull.InfiniteScroll = {
  setupScroll: function(){
    this.firstPage();
    this.$window().scroll(this.onScroll);
  },

  firstPage: function(){
    this.EOF = false;
    this.filter.page = 1;
    this.$results.html('');
  },

  fetchPage: function(){
    // the isLoaderDivVisible check if the div is already in the view pane to load more content
    // the $loader.is(:visible) is here to avoid trigerring two concurrent fetchPage calls
    if(this.isLoaderDivVisible() && !this.$loader.is(':visible') && !this.EOF){
      this.$loader.show();
      $.get(this.path, this.filter).success(this.onSuccess);
      this.filter.page += 1;
    }
  },

  onSuccess: function(data){
    if($.trim(data) == ''){
      this.EOF = true;
    }
    this.$results.append(data);
    this.$loader.hide();
    this.trigger('scroll:success', data);
  },

  $window: function(){
    return $(window);
  },

  isLoaderDivVisible: function(){
    return this.$loaderDiv.is(':visible') && this.$window().scrollTop() + this.$window().height() >  this.$loaderDiv.offset().top;
  },

  onScroll: function(event){
    this.fetchPage();
  }
};
