app.AdminContributions_list = {
  controller: function(args) {
    this.contributions = m.prop(args.contributions || new app.Contribution())
  },
  view: function(ctrl) {
    return m("table", [
      ctrl.contributions().map(function(contribution) {
        return m("tr", [
          m("td", contribution.id),
          m("td", contribution.name),
          m("td", contribution.email)
        ])
      })
    ])
  }
}