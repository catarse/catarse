App.addChild('UserLinksForm', {
  el: '#links',

  activate: function() {
    this.nestedLinksSetup();
    this.$el.on('cocoon:after-insert', function(e, insertedItem) {
      that.nestedLinksSetup();
    });
  },

  nestedLinksSetup: function() {
    var that = this;
    this.$('a.add-user-link').unbind('click');
    this.$('a.add-user-link').bind('click', function(event) {
      that.$('a.user-links.add_fields').trigger('click');
    });
  }
})
