App.addChild('Explore', _.extend({
  el: '#main_content[data-action="index"][data-controller-name="explore"]',

  routeFilters: {
    recent: { recent: true },
    expiring: { expiring: true },
    recommended: { recommended: true },
    successful: { successful: true }
  },

  activate: function(){
    this.$loader = this.$("#loading img");
    this.$loaderDiv = this.$("#loading");
    this.$results = this.$(".results");
    this.path = this.$("#explore_results").data('projects-path');

    this.route('recommended');
    this.route('expiring');
    this.route('recent');
    this.route('successful');
    this.route('by_category_id/:id');
    this.route('near_of/:state');

    this.setInitialFilter();
    this.setupScroll();

    if(window.location.hash == ''){
      this.fetchPage();
    }
  },

  selectLink: function(){
    this.$('a.selected').removeClass('selected');
    this.$('a[href="' + window.location.hash + '"]').addClass('selected');
  },

  followRoute: function(route, name, params){
    this.filter = {};
    if(params.length > 0){
      this.filter[name] = params[0];
    }
    else{
      this.filter[name] = true;
    }
    this.firstPage();
    this.fetchPage();
    if(this.parent && this.parent.$search.length > 0){
      this.parent.$search.val('');
    }
    this.selectLink();
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
  }
}, Skull.InfiniteScroll));
