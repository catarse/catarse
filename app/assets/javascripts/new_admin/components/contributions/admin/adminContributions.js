//contributions.admin_contributions.js
app.AdminContributions = {
    controller: function update() {
        this.contributions = Contribution.list()
    },
    view: function(ctrl) {
        console.log("Will call this thing a view.");
        return [
            m.component(app.AdminContributions_filter),
            m.component(app.AdminContributions_list, {contributions: ctrl.contributions})
        ]
    }
}