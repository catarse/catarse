import m from 'mithril';
import prop from 'mithril/stream';
import { catarse } from '../api';
import _ from 'underscore';
import h from '../h';
import models from '../models';
import projectDashboardMenu from '../c/project-dashboard-menu';
import projectVM from '../vms/project-vm';

const fiscalScope = _.partial(h.i18nScope, 'projects.dashboard_fiscal');

const projectFiscals = {
    oninit: function(vnode) {
        const loader = catarse.loaderWithToken,
            filterVM = catarse.filtersVM({
                project_id: 'eq'
            }),
            {
                project_id
            } = vnode.attrs,
            projectDetail = h.RedrawStream({}),
            debitNotes = h.RedrawStream({}),
            informs = h.RedrawStream({});
        filterVM.project_id(project_id);

        const getRowOptions = models.projectDetail.getRowOptions(filterVM.parameters());
        const l = catarse.loaderWithToken(getRowOptions);
        l.load().then((data) => {
            projectDetail(_.first(data) || {});
        });

        const listInfomrs = {
            submit: () => {
                m.request({
                    method: 'GET',
                    url: `/projects/${vnode.attrs.project_id}/inform_years`,
                    config: h.setCsrfToken
                }).then((data) => {
                   informs(_.map(data.result));
                }).catch(() => {
                    informs({})
                });
            }
        };

        const listDebitNotes = {
            submit: () => {
                m.request({
                    method: 'GET',
                    url: `/projects/${vnode.attrs.project_id}/debit_note_end_dates`,
                    config: h.setCsrfToken
                }).then((data) => {
                    debitNotes(_.map(data));
                }).catch(() => {
                    debitNotes({})
                });
            }
        };

        listInfomrs.submit();
        listDebitNotes.submit();

        vnode.state = {
            l,
            projectDetail,
            debitNotes,
            informs
        };
    },
    view: function({state, attrs}) {
        const project = state.projectDetail();
        const debitNotes = state.debitNotes();
        const informs = state.informs();
        const loading = state.l();
        const hasData = !loading && (!_.isEmpty(debitNotes[0]) || !_.isEmpty(informs[0]));
        console.log(_.map(debitNotes[0]));
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
                                    m('ul.w-list-unstyled', _.map(informs, (inform, idx) => [
                                        (idx > 0 ? m('li.divider.u-marginbottom-10') : ''),
                                        m('li.fontsize-smaller.u-marginbottom-10',
                                            m('div', [
                                                'Informe de Rendimentos -',
                                                m.trust('&nbsp;'),
                                                m(`a.alt-link[href='/projects/${project.project_id}/project_inform/${inform}']`,
                                                    inform
                                                ),
                                                m.trust('&nbsp;')
                                            ])
                                        )])
                                    ),
                                    m('ul.w-list-unstyled', _.map(debitNotes[0], (note, idx) => [
                                        (idx > 0 || !_.isEmpty(debitNotes[0]) ? m('li.divider.u-marginbottom-10') : ''),
                                        m('li.fontsize-smaller.u-marginbottom-10',
                                            m('div', [
                                                'Nota de Débito -',
                                                m.trust('&nbsp;'),
                                                m(`a.alt-link[href='/projects/${project.project_id}/project_debit_note/${note.project_fiscal_id}']`,
                                                   note.end_date
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

export default projectFiscals;
