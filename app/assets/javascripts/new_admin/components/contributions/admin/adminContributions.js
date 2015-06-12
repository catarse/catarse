//contributions.admin_contributions.js
admin_app.AdminContribution = {
    controller: function() {
      var contributions = this.contributions = admin_app.Contribution.get();
      this.filterContributions = function(filter){
        console.log("Filtering contributions with: ");
        console.log(filter);
        contributions = admin_app.Contribution.get(filter);
        return;
      };
    },
    view: function(ctrl) {
      return  [ 
                m.component(admin_app.AdminContributions_filter,{onFilter: ctrl.filterContributions}),
                m(".w-section.section",[
                  m.component(admin_app.AdminContributions_list, {contributions: ctrl.contributions}),
                ]),
                m(".w-section.section",[
                  m(".w-container",[
                    m(".w-row",[
                      m(".w-col.w-col-5"),
                      m(".w-col.w-col-2",[
                        m("a.btn.btn-medium.btn-terciary[href='#']", "Carregar mais")
                      ]),
                      m(".w-col.w-col-5")
                    ])
                  ])
                ])
              ];   
    }
}