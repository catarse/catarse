admin_app.AdminContributions_list = {
  controller: function(args) {
    this.contributions = m.prop(args.contributions || new admin_app.Contribution());
  },
  view: function(ctrl, args) {
    return m(".w-container",[
            m(".u-marginbottom-30.fontsize-base",[
              m("span.fontweight-semibold", "125")," apoios encontrados, totalizando ",
              m("span.fontweight-semibold", [
                "R$27.090.655,00     ",
                m("a.fa.fa-download.fontcolor-dashboard[href='#']",
                 ".")
              ])
            ]),
            ctrl.contributions().map(function(contribution){
              return m.component(admin_app.AdminContributions_list_detail, {contribution: contribution, key: contribution});
            })
          ]);    
  }
}