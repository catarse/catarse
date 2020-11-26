import m from 'mithril';
import moment from 'moment';
import h from '../h';
import { Report } from '../vms/project-report-exports-vm';

export const projectSubscriptionReportDownloadEntry = {

    view({attrs}) {

        /** @type {Report} */
        const {
            id,
            project_id,
            report_type,
            report_type_ext,
            state,
            created_at,
        } = attrs;

        const reportTypeTranslatedName = {
            SubscriptionReportForProjectOwner: 'Base de Assinantes',
            SubscriptionMonthlyReportForProjectOwner: 'Pagamentos confirmados',
        };

        const isExpired = state === 'expired' || moment(created_at).add(7, 'days').isBefore(Date.now());

        const realState = isExpired ? 'expired' : state;

        const reportStateBadge = {
            pending: realState === 'pending' && m("span.fontsize-smaller.badge.btn-messenger.fontcolor-negative", "Processando"),
            expired: realState === 'expired' && m("span.fontsize-smaller.badge.badge-gone", "Expirado"),
            done: realState === 'done' && m("span.fontsize-smaller.badge.badge-success", "Finalizado"),
        };

        const reportIconByState = {
            pending: realState === 'pending' && m('div.w-col.w-col-1', h.loaderWithSize(30, 30)),
            expired: null,
            done: realState === 'done' && m("div.fa.fa-check-circle.text-success.fa-2x.w-col.w-col-1"),
        };

        const shouldDisplayDownloadButton = realState === 'done';

        const reportDownloadUrl = () => `/projects/${project_id}/project_report_exports/${id}/`

        return m(`div.card.u-marginbottom-10`, {
            class: isExpired ? 'card-terciary' : ''
        }, [
            m('div.u-marginbottom-20.w-row', [
                (
                    isExpired ?
                        m('div.fontsize-small.fontweight-semibold.u-marginbottom-20', reportTypeTranslatedName[report_type])
                    :
                        [
                            reportIconByState[realState],
                            m('div.w-col.w-col-8',
                                m('div.fontsize-small.fontweight-semibold.u-marginbottom-20', reportTypeTranslatedName[report_type])
                            ),
                            m('div.w-col.w-col-3', [
                                shouldDisplayDownloadButton &&
                                    m(`a.btn.btn-small.btn-dark.w-button[href="${reportDownloadUrl()}"]`, [
                                        m('span.fa.fa-download', ' '),
                                        ' Baixar arquivo'
                                    ])
                            ])
                        ]
                )
            ]),
            m('div.w-row', [
                m('div.w-col.w-col-4', [
                    m('div.fontsize-smaller.fontweight-semibold', 'Status:'),
                    m('div',  reportStateBadge[realState])
                ]),
                m('div.w-col.w-col-5', [
                    m('div.fontsize-smaller.fontweight-semibold', 'Data da exportação:'),
                    m('div.fontsize-smaller.fontweight-semibold', moment(created_at).format('DD/MM/YYYY (h[h]mma)'))
                ]),
                m("div.w-col.w-col-3", [
                    m("div.fontsize-smaller.fontcolor-secondary", "Formato:"),
                    m("div.fontsize-smaller.fontcolor-secondary", report_type_ext.toUpperCase())
                ])
            ])
        ]);
    }

};