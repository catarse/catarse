App.addChild('Sort', {
  el: '.admin.use-sort',

  events: {
    'click [data-sort]' : 'sort'
  },

  activate: function(){
    this.form = this.$('form.simple_form');
    this.table = this.$('table');
    this.selectSorting();
  },

  getSorting: function(){
    var sortField = this.form.find('[id=_order_by]');

    if(sortField.val()){
      var sort = sortField.val().split(' ');
      return {field: sort[0], order: sort[1]};
    }
    return undefined;
  },

  selectSorting: function(){
    if(this.getSorting()){
      var link = this.$('a[data-sort="' + this.getSorting().field + '"]');
      var sortOrder = link.siblings('span.sort-order');
      // Clean old sort orders
      this.$('[data-sort]').siblings('span.sort-order').html('');

      // Add sorting order to header
      if(this.getSorting().order == 'DESC'){
        sortOrder.html('(desc)');
      }
      else {
        sortOrder.html('(asc)');
      }
    }
  },

  sort: function(event){
    var link = $(event.target);
    var sortField = this.form.find('[id=_order_by]');

    // Put sorting data in hidden field and select sorting
    sortField.val(link.data('sort') + ' ' + (this.getSorting().order == 'ASC' ? 'DESC' : 'ASC'));
    this.selectSorting();
    this.form.submit();
    return false;
  }
});
