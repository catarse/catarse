//contributions.admin_contributions.js
app.AdminContributions = {
    controller: function() {
      this.getContributions = function(filter){
        var contributions = {};
        contributions = (filter) ? Contributions.get(filter) : Contributions.get();
        return contributions;
      };
      this.filter = app.submodule(app.AdminContributions_filter,{onFilter: this.getContributions});
      this.list = app.submodule(app.AdminContributions_list, {contributions: this.getContributions});
    },
    view: function(ctrl) {
      return  [ 
                ctrl.filter(),
                m(".w-section.section",[
                  ctrl.list(),
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