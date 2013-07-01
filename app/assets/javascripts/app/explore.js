App.addChild('Explore', _.extend({
  el: '#main_content[data-action="index"][data-controller-name="explore"]',

  events: {
    'click a[data-filter]' : 'applyFilter'
  },

  activate: function(){
    this.$loader = this.$("#loading img");
    this.$loaderDiv = this.$("#loading");
    this.$results = this.$(".results");
    this.path = this.$("#explore_results").data('projects-path');
    this.setInitialFilter();
    this.setupScroll();
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
  }
}, Skull.InfiniteScroll));
