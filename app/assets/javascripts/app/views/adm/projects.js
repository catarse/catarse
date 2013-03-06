CATARSE.Adm.Projects = {
  Index: Backbone.View.extend({
    mask_inputs: function() {
    $('#between_created_at_start_at, #between_created_at_ends_at').mask("99/99/9999");
    },

    initialize: function() {
      this.mask_inputs();
    }
  })
}
