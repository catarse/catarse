import m from 'mithril';
export const RequestedSubscriptionReportsModal = {

    view({ state, attrs }) {

        /** @type {string} */
        const reportsExportingUrl = attrs.reportsExportingUrl;

        /** @type {string} */
        const projectUserEmail = attrs.projectUserEmail;

        /** @type {() => void} */
        const onClose = attrs.onClose;

        return m('div.modal-dialog-inner.modal-dialog-small', [
            m('a.modal-close.fa.fa-close.fa-lg.w-inline-block[href="#"]', { onclick: onClose }),
            m('div.modal-dialog-header',
                m('div.fontsize-large.u-text-center', 'Exportar relatórios')
            ),
            m('div.modal-dialog-content.u-text-center', [
                m('div.fa.fa-check-circle.fa-5x.text-success.u-marginbottom-40'), 
                m('div.fontsize-large', 
                  'Pronto! Estamos preparando seu arquivo.'
                ), 
                m('div.fontsize-small',
                  [
                    'Você pode acompanhar o progresso da exportação. Ao finalizar, também enviaremos uma cópia do arquivo para o email ',
                    m('span.fontweight-semibold', projectUserEmail),
                    '.'
                  ]
                )
            ]),
            m('div.modal-dialog-nav-bottom',
                m('div.w-row', [
                    m('div.w-col.w-col-2'),
                    m('div.w-col.w-col-8', 
                        m(`a.btn.btn-medium[href='${reportsExportingUrl}']`, [
                            "Acompanhar progresso ",
                            m.trust("&gt;")
                        ])
                    ),
                    m("div.w-col.w-col-2")
                ])
            )
        ]);

    }
};