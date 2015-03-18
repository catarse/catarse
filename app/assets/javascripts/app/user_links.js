App.addChild('UserLinksForm', {
  
  el: '#links',

  events: {
    'click #add-link': 'addLink',
    'click .remove_fields': 'removeLink'
  },

  addLink: function(event){

    event.preventDefault();

    this.$('a.user-links.add_fields').trigger('click');

  },

  removeLink: function(event){

    var $target = this.$(event.target),
        $container = $target.closest('.w-row');

    event.preventDefault();

    $container.slideUp();

    //check if link been removed is already saved by looking for a hidden input value
    if($target.prev().val() === "false"){

      $target.prev().val('true');
      
    }else{

      $container.promise().done(function(){

        $container.remove();
      
      });

    }

  }
  
});