app.AdminContributions_list = {
    controller: function(args) {
        this.contribution = m.prop(args.contribution || new app.Contribution())
    },
    view: function(ctrl, args) {
        return m("table", [
            args.contributions().map(function(contribution) {
                return m("tr", [
                    m("td", contribution.id()),
                    m("td", contribution.name()),
                    m("td", contribution.email())
                ])
            })
        ])
    }
}