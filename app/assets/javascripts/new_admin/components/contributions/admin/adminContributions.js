//contributions.admin_contributions.js
app.AdminContributions = {
    controller: function() {
      this.contributions = Contributions.list();
    },
    view: function(ctrl) {
      return  [
                m.component(app.AdminContributions_filter),
                m(".w-section.section",[
                  m.component(app.AdminContributions_list, {contributions: ctrl.contributions})
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
              ]   
    }
}