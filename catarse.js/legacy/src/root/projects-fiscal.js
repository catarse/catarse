import m from 'mithril';
import prop from 'mithril/stream';
import { catarse } from '../api';
import _ from 'underscore';
import h from '../h';
import models from '../models';
import projectDashboardMenu from '../c/project-dashboard-menu';
import projectVM from '../vms/project-vm';

const fiscalScope = _.partial(h.i18nScope, 'projects.dashboard_fiscal');

const projectsFiscal = {
    oninit: function(vnode) {
        const loader = catarse.loaderWithToken,
            filterVM = catarse.filtersVM({
                project_id: 'eq'
            }),
            {
                project_id
            } = vnode.attrs,
            projectDetail = h.RedrawStream({}),
            projectFiscalData = h.RedrawStream({});
        filterVM.project_id(project_id);
        const l = loader(models.projectFiscalId.getRowOptions(filterVM.parameters()));
        l.load().then((data) => {
            projectFiscalData(_.first(data) || {});
        });
        const l2 = loader(models.projectDetail.getRowOptions(filterVM.parameters()));
        l2.load().then((data) => {
            projectDetail(_.first(data) || {});
        });
        vnode.state = {
            l,
            l2,
            projectDetail,
            projectFiscalData
        };
    },
    view: function({state, attrs}) {
        const project = state.projectDetail();
        const projectFiscalData = state.projectFiscalData();
        const loading = state.l() || state.l2();
        const hasData = !loading && projectFiscalData && (!_.isEmpty(projectFiscalData.debit_notes) || !_.isEmpty(projectFiscalData.informs));

        return m('.project-fiscal',
            (project.is_owner_or_admin ? m(projectDashboardMenu, {
                project: prop(project)
            }) : ''),
            m('.section',
                m('.w-container',
                    m('.w-row', [
                        m('.w-col.w-col-2'),
                        m('.w-col.w-col-8', [
                            m('.fontsize-larger.fontweight-semibold.lineheight-looser.u-text-center',
                                window.I18n.t('title', fiscalScope())
                            ),
                            m('.fontsize-base.u-text-center',
                                window.I18n.t('subtitle', fiscalScope())
                            ),
                            m('.u-margintop-20.u-text-center',
                                m('.w-inline-block.card.fontsize-small.u-radius', [
                                    m('span.fa.fa-lightbulb-o',
                                        ''
                                    ),
                                    m.trust('&nbsp;'),
                                    m.trust(window.I18n.t('help_link', fiscalScope()))
                                ])
                            )
                        ]),
                        m('.w-col.w-col-2')
                    ])
                )
            ),
            m('.divider'),
            (!loading ?
            m('.before-footer.section',
                m('.w-container', [
                    (!hasData ?
                        m('.w-row', [
                            m('.w-col.w-col-2'),
                            m('.w-col.w-col-8',
                                m('.card.card-message.u-marginbottom-40.u-radius',
                                    m('.fontsize-base', [
                                        m('span.fa.fa-exclamation-circle',
                                            ''
                                        ),
                                        window.I18n.t(!projectVM.isSubscription(project) ?
                                            'nodoc_explanation'
                                            : 'nodoc_explanation_sub', fiscalScope())
                                    ])
                                )
                            ),
                            m('.w-col.w-col-2')
                        ])
                        :
                        m('.w-row', [
                            m('.w-col.w-col-2'),
                            m('.w-col.w-col-8',
                                m('.card.u-radius.u-marginbottom-20.card-terciary', [
                                    m('.fontsize-small.fontweight-semibold.u-marginbottom-20', [
                                        m('span.fa.fa-download',
                                            m.trust('&nbsp;')
                                        ),
                                        window.I18n.t('doc_download', fiscalScope())
                                    ]),
                                    m('.card.u-radius.u-marginbottom-20', [
                                        m('span.fontweight-semibold',
                                            m.trust('Atenção:')
                                        ),
                                        m.trust(window.I18n.t('doc_download_explanation', fiscalScope()))
                                    ]),
                                    m('ul.w-list-unstyled', _.map(projectFiscalData.informs, (inform, idx) => [
                                        (idx > 0 ? m('li.divider.u-marginbottom-10') : ''),
                                        m('li.fontsize-smaller.u-marginbottom-10',
                                            m('div', [
                                                'Informe de Rendimentos -',
                                                m.trust('&nbsp;'),
                                                m(`a.alt-link[href='/projects/${project.project_id}/inform/${inform}']`,
                                                    inform
                                                ),
                                                m.trust('&nbsp;')
                                            ])
                                        )])
                                    ),
                                    m('ul.w-list-unstyled', _.map(projectFiscalData.debit_notes, (note, idx) => [
                                        (idx > 0 || !_.isEmpty(projectFiscalData.informs) ? m('li.divider.u-marginbottom-10') : ''),
                                        m('li.fontsize-smaller.u-marginbottom-10',
                                            m('div', [
                                                'Nota de Débito -',
                                                m.trust('&nbsp;'),
                                                m(`a.alt-link[href='/projects/${project.project_id}/debit_note/${note}']`,
                                                    note.replace(/^(\d\d\d\d)(\d\d)(\d\d)$/, '$3/$2/$1')
                                                ),
                                                m.trust('&nbsp;')
                                            ])
                                        )])
                                    )
                                ])
                            ),
                            m('.w-col.w-col-2')
                        ])

                    ),
                ]
                )
            )
            : h.loader())
        );
    }
};

export default projectsFiscal;
