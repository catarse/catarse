var PaginatedView = Backbone.View.extend({
  initialize: function(){
    typeof(options) != 'undefined' || (options = {})
    if(options.collection)
      this.collection = options.collection
    if(options.modelView)
      this.modelView = options.modelView
    this.loader.waypoint('destroy')
    _.bindAll(this, "render", "update", "nextPage", "waypoint")
    this.render()
    this.loader.show()
    this.collection.page = 1
    this.collection.bind("reset", this.update)
    this.collection.fetch()
  },
  waypoint: function(event, direction){
    if(!this.loader.is(":visible")){
      this.loader.waypoint('remove')
      if(direction == "down")
        this.nextPage()
    }
  },
  nextPage: function(){
    if(!this.collection.isEmpty()) {
      this.loader.show();
      this.collection.nextPage();
    }
  },
  render: function() {
		var $backers,
				collection = this.collection;
		$(this.el).append(this.template({}));
		$backers = this.$("#collection_list");

		this.collection.each(function(backer) {
			var view = new BackerView({
				model: backer,
				collection: collection
			});

			$backers.append(view.render().el)
		});
		return this;
    // this.$('ul.items').html("")
    // this.$('.empty').hide()
    // return this
  },
  update: function(){
    this.loader.$("img").hide()
    if(!this.collection.isEmpty()) {
      this.collection.each(function(model){
        var item = $('<li>')
        this.$('ul.items').append(item)
        new this.view({el: item, model: model})        
      }, this)
    } else if(this.collection.page == 1) {
      this.$('.empty').show()
    }
    this.loader.waypoint(this.waypoint, {offset: "100%"})
    return this
  }
})
