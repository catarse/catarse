var PaginatedView = Backbone.View.extend({
  initialize: function(){
    typeof(options) != 'undefined' || (options = {})
    if(options.collection)
      this.collection = options.collection
    if(options.modelView)
      this.modelView = options.modelView
		// if(options.loader)
		// 	this.loader = options.loader
		this.loader = $("#loading")
    this.loader.waypoint('destroy')
    _.bindAll(this, "render", "update", "nextPage", "waypoint")
    this.render();
		this.loader.show();
    // this.collection.bind("reset", this.update);
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
      // this.loader.children().show();
      this.collection.nextPage();
    }
		return this;
  },
  render: function() {
		var $list,
				collection = this.collection;
		// $(this.el).append(this.template({}));
		$list = this.$(".collection_list");

		this.collection.each(function(item) {
			var view = new this.modelView({
				model: item,
				collection: collection
			});

			$list.append(view.render().el)
		});
		// 
		// $(this.el).append($list);
		// this.loader.children().hide();
		return this;
    // this.$('ul.items').html("")
    // this.$('.empty').hide()
    // return this
  },
  update: function(){
    // this.loader.children().hide()
    if(!this.collection.isEmpty()) {
      this.collection.each(function(model){
        var item = $('<li>')
        this.$('ul.items').append(item)
        new this.view({el: item, model: model})        
      }, this)
    } else if(this.collection.page == 1) {
      this.$('.empty').show()
    }
    // this.loader.waypoint(this.waypoint, {offset: "100%"})
    return this
  }
})
