Skull.InfiniteScroll = {
  setupScroll: function(){
    this.firstPage();
    this.$window().scroll(this.onScroll);
  },

  firstPage: function(){
    this.EOF = false;
    this.filter.page = 1;
    this.$results.html('');
    this.fetchPage();
  },

  fetchPage: function(){
    if(!this.EOF){
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
  },

  $window: function(){
    return $(window);
  },

  isLoaderVisible: function(){
    return this.$loaderDiv.is(':visible') && this.$window().scrollTop() + this.$window().height() >  this.$loaderDiv.offset().top;
  },

  onScroll: function(event){
    if(this.isLoaderVisible()){
      this.fetchPage();
    }
  }
};
