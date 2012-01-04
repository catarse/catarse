CATARSE.User = Backbone.Model.extend({
	initialize: function() {
		this.backs = new CATARSE.UserBacks()
		this.backs.url = '/' + CATARSE.locale + '/users/' + this.id + '/backs'
	}
})
