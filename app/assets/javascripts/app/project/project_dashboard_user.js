App.addChild('DashboardUserSettings', {
  el: '#dashboard-user_settings-tab',

  events:{
    "change .account_type": "changeType",
    "change .project_account_attributes_agency": "padZeros"
  },

  activate: function() {
    var mode = ($(this.el).data('mode') === 'flex' ? 'flexible_' : '');
    this.$inscription = this.$("."+mode+"project_account_state_inscription");
    this.changeType();
  },

  padZeros: function(field) {
    field = this.$('.project_account_attributes_agency');
    field.val(("0000" + field.val()).substr(-4,4));

    return true;
  },

  changeType: function () {
    var mode = ($(this.el).data('mode') === 'flex' ? 'flexible_' : '');
    var type = $( ".account_type option:selected" ).text();
    var label_text;

    if (type == 'Pessoa Física') {
      label_text = this.$("#"+mode+"project_account_attributes_owner_name").data('natural');
      document_label_text = this.$("#"+mode+"project_account_attributes_owner_document").data('natural');
      this.$inscription.hide();
      this.$(".user-document").prop('maxlength', 11);
      this.$(".user-document").fixedMask('999.999.999-99');
    }
    else if (type == 'Pessoa Jurídica') {
      label_text = this.$("#"+mode+"project_account_attributes_owner_name").data('juridical');
      document_label_text = this.$("#"+mode+"project_account_attributes_owner_document").data('juridical');
      this.$inscription.show();
      this.$(".user-document").prop('maxlength', 14);
      this.$(".user-document").fixedMask('99.999.999/9999-99');
    }

    this.$("."+mode+"project_account_owner_name > label:first-child").html(label_text);
    this.$("."+mode+"project_account_owner_document > label:first-child").html(document_label_text);
  }


});

App.addChild('DashboardUserSettingsForm', _.extend({
  el: '#project_account_form',

  events: {
    'blur input' : 'checkInput',
    'click input[type="submit"]' : 'validate',
    "keydown #project_account_attributes_account": "allowOnlyNumbers"
  },

  activate: function(){
    this.setupForm();
  },

  allowOnlyNumbers: function (e) {
    // Allow: backspace, delete, tab, escape and enter
    if ($.inArray(e.keyCode, [ 8, 9, 27, 13, 110]) !== -1 ||
       // Allow: Ctrl+A
      (e.keyCode == 65 && e.ctrlKey === true) ||
       // Allow: Ctrl+C
      (e.keyCode == 67 && e.ctrlKey === true) ||
       // Allow: Ctrl+X
      (e.keyCode == 88 && e.ctrlKey === true) ||
       // Allow: home, end, left, right
      (e.keyCode >= 35 && e.keyCode <= 39)) {
           // let it happen, don't do anything
           return;
    }
    // Ensure that it is a number and stop the keypress
    if ((e.shiftKey || (e.keyCode < 48 || e.keyCode > 57)) && (e.keyCode < 96 || e.keyCode > 105)) {
      e.preventDefault();
    }
  }

}, Skull.Form));
