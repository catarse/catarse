App.addChild('DashboardUserSettings', {
  el: '#dashboard-user_settings-tab',

  events:{
    "change .account_type": "changeType"
  },

  activate: function() {
    this.$inscription = this.$(".project_account_state_inscription");
    this.changeType();
  },

  changeType: function () {
    var type = $( ".account_type option:selected" ).text();
    var label_text;

    if (type == 'Pessoa Física') {
      label_text = this.$("#project_account_attributes_full_name").data('natural');
      this.$inscription.hide();
      this.$(".user-document").prop('maxlength', 11);
      this.$(".user-document").fixedMask('999.999.999-99');
    }
    else if (type == 'Pessoa Jurídica') {
      label_text = this.$("#project_account_attributes_full_name").data('juridical');
      this.$inscription.show();
      this.$(".user-document").prop('maxlength', 14);
      this.$(".user-document").fixedMask('99.999.999/9999-99');
    }

    this.$(".project_account_full_name > label:first-child").html(label_text);
  }


});
