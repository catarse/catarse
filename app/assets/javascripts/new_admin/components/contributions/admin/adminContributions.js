//contributions.admin_contributions.js
app.AdminContributions = {
    controller: function() {
      this.contributions = Contributions.list();
    },
    view: function(ctrl) {
      return [
          m.component(app.AdminContributions_filter),
          m.component(app.AdminContributions_list, {contributions: ctrl.contributions})
      ]
    }
}