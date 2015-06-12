admin_app.AdminContributions_filter = {
  controller: function(args){
    var vm = this.vm = admin_app.AdminContributions_filter.vm;
    this.filter = function(){
      args.onFilter(vm.filter());
    };
  },
  view: function(ctrl, args) {
    return m(".w-section.page-header",[
            m(".w-container",[
              m(".fontsize-larger.u-text-center.u-marginbottom-30", "Apoios"),
              m(".w-form",[
                m("form[data-name='Email Form'][id='email-form'][name='email-form']", [
                  m(".w-row.u-marginbottom-20", [
                    m(".w-col.w-col-2", [
                      m("label.fontsize-small[for='permalink']", "Permalink"),
                      m("input.w-input.text-field.positive[id='permalink'][name='permalink'][placeholder='permalink do projeto'][required='required'][type='text']",{onchange: m.withAttr("value", ctrl.vm.permalink), value: ctrl.vm.permalink()})
                    ]),
                    m(".w-col.w-col-4", [
                      m("label.fontsize-small[for='expiration']", "Expiram entre"),
                      m("input.w-input.text-field.positive[data-name='Field 2'][id='expiration'][name='expiration'][placeholder='Expiram entre'][required='required'][type='text']")
                    ]),
                    m(".w-col.w-col-2", [
                      m("label.fontsize-small[for='progress']", "Por progresso %"),
                      m("input.w-input.text-field.positive[data-name='Field 2'][id='progress'][name='progress'][placeholder='Progresso em %'][required='required'][type='text']")
                    ]),
                    m(".w-col.w-col-2", [
                      m("label.fontsize-small[for='field-3']", "Com o estado"),
                      m("select.w-select.text-field.positive[id='field-3'][name='field-3']", [
                        m("option[value='']", "Select one..."),
                        "\n",
                        m("option[value='First']", "First Choice"),
                        "\n",
                        m("option[value='Second']", "Second Choice"),
                        "\n",
                        m("option[value='Third']", "Third Choice")
                      ])
                    ]),
                    m(".w-col.w-col-2", [
                      m("label.fontsize-small[for='field-3']", "Meio de pag."),
                      m("select.w-select.text-field.positive[id='field-3'][name='field-3']", [
                        m("option[value='']", "Select one..."),
                        "\n",
                        m("option[value='First']", "First Choice"),
                        "\n",
                        m("option[value='Second']", "Second Choice"),
                        "\n",
                        m("option[value='Third']", "Third Choice")
                      ])
                    ])
                  ])
                ]),
                m(".w-form-done", [
                  m("p", "Thank you! Your submission has been received!")
                ]),
                m(".w-form-fail", [
                  m("p", "Oops! Something went wrong while submitting the form :(")
                ])
              ]),
              m(".w-row", [
                m(".w-col.w-col-4"),
                m(".w-col.w-col-4", [
                  m("button.btn.btn-small", {onclick: ctrl.filter},"Filtrar")
                ]),
                m(".w-col.w-col-4")
              ])
            ])
          ]);
  }
};