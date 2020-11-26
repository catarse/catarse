import m from 'mithril';
import stream from 'mithril/stream';
import h from '../h';

export const SelectSubscriptionReports = {
    oninit(vnode) {

        const reportsExtension = stream('csv');
        const selectedReportTypes = [];

        vnode.state = {
            getSelectedReportTypes: () => selectedReportTypes,
            selectReportType: (report_type, checked) => {
                const indexIn = selectedReportTypes.indexOf(report_type);
                const isInside = indexIn >= 0;
                if (checked && !isInside) {
                    selectedReportTypes.push(report_type);
                } else if (isInside) {
                    selectedReportTypes.splice(indexIn, 1);
                }
            },
            reportsExtension,
        };
    },

    view({ state, attrs }) {

        const onSend = attrs.onSend;
        const onClose = attrs.onClose;
        const isSending = attrs.isSending();

        const selectReportType = state.selectReportType;
        const getSelectedReportTypes = state.getSelectedReportTypes;
        const reportsExtension = state.reportsExtension;

        const reportsTypeSelection = [
            {
                value: 'SubscriptionReportForProjectOwner',
                name: 'Base de Assinantes'
            },
            {
                value: 'SubscriptionMonthlyReportForProjectOwner',
                name: 'Pagamentos confirmados'
            }
        ];

        return m('div.modal-dialog-inner.modal-dialog-small', [
            m('a.modal-close.fa.fa-close.fa-lg.w-inline-block[href="#"]', { onclick: onClose }),
            m('div.modal-dialog-header',
                m('div.fontsize-large.u-text-center', 'Exportar relatórios')
            ),
            [
                (isSending) ?
                    h.loader()
                :
                    [
                        m('div.modal-dialog-content', [
                            m('div.u-marginbottom-30', [
                                m('div.fontsize-base.u-marginbottom-10',
                                    m('span.fontweight-semibold',
                                        'Qual destes relatórios você deseja exportar?'
                                    )
                                ),
                                m('div.w-form', [
                                    m(`form`,
                                        reportsTypeSelection.map(reportTypeCheck => {
                                            return m('label.w-checkbox.fontsize-base', [
                                                m(`input.w-checkbox-input[type="checkbox"][name="report_type"][value="${reportTypeCheck.value}"]`, {
                                                    onclick: (event) => selectReportType(event.target.value, event.target.checked)
                                                }),
                                                m('span.w-form-label', reportTypeCheck.name)
                                            ]);
                                        })
                                    ),
                                ])
                            ]),
                            m('div', [
                                m('div.fontsize-base.u-marginbottom-10',
                                    m('span.fontweight-semibold', 'Formato do arquivo')
                                ),
                                m('div.w-form', [
                                    m('form',
                                        m('select.text-field.w-select', {
                                            value: reportsExtension(),
                                            onchange: (event) => reportsExtension(event.target.value),
                                        }, [
                                            m('option[value="csv"]', 'CSV padrão'),
                                            m('option[value="xls"]', 'Excel (XLS)'),
                                        ])
                                    )
                                ])
                            ])
                        ]),
                        m('div.modal-dialog-nav-bottom',
                            m('div.w-row', [
                                m('div.w-col.w-col-3'),
                                m('div.w-col.w-col-6',
                                    m('a.btn.btn-medium[href="#"]', { 
                                        onclick: () => {
                                            onSend(getSelectedReportTypes(), reportsExtension())
                                        } 
                                    }, [
                                        'Avançar ', 
                                        m.trust('&gt;')
                                    ])
                                ),
                                m('div.w-col.w-col-3')
                            ])
                        )
                    ]
            ]
        ]);

    }
};