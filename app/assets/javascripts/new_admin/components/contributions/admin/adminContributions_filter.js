app.AdminContributions_filter = {
  view: function(ctrl, args) {
    return m(".w-section.page-header",[
            m(".w-container",[
              m(".fontsize-larger.u-text-center.u-marginbottom-30", "Apoios"),
              m(".w-form",[
                m("form[data-name='Email Form'][id='email-form'][name='email-form']", [
                  m(".w-row.u-marginbottom-20", [
                    m(".w-col.w-col-2", [
                      m("label.fontsize-small[for='field']", "Permalink"),
                      m("input.w-input.text-field.positive[id='field'][name='field'][placeholder='Example Text'][required='required'][type='text']")
                    ]),
                    m(".w-col.w-col-4", [
                      m("label.fontsize-small[for='field-2']", "Expiram entre"),
                      m("input.w-input.text-field.positive[data-name='Field 2'][id='field-2'][name='field-2'][placeholder='Example Text'][required='required'][type='text']")
                    ]),
                    m(".w-col.w-col-2", [
                      m("label.fontsize-small[for='field-2']", "Por progresso %"),
                      m("input.w-input.text-field.positive[data-name='Field 2'][id='field-2'][name='field-2'][placeholder='Example Text'][required='required'][type='text']")
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
                  m("a.btn.btn-small[href='#']", "Filtrar")
                ]),
                m(".w-col.w-col-4")
              ])
            ])
          ]);
  }
}