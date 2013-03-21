CATARSE.Adm.Financials = {
  Index: Backbone.View.extend({
    mask_inputs: function() {
      $('#between_expires_at_start_at, #between_expires_at_ends_at').mask("99/99/9999");
    },

    initialize: function() {
      this.mask_inputs();
    }
  })
}
