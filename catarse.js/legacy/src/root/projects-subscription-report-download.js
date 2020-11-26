import m from 'mithril';
import prop from 'mithril/stream';
import _ from 'underscore';
import projectDashboardMenu from '../c/project-dashboard-menu';
import {
    catarse
} from '../api';
import projectsContributionReportVM from '../vms/projects-contribution-report-vm';
import h from '../h';
import models from '../models';
import { projectSubscriptionReportDownloadEntry } from '../c/project-subscription-report-download-entry';
import { listProjectReportExports, Report } from '../vms/project-report-exports-vm';
import loadMoreBtn from '../c/load-more-btn';

const projectSubscriptionReportDownload = {
    oninit: function (vnode) {
        const catarseVM = projectsContributionReportVM;
        const reports = prop([]);
        const loading = prop(true);
        const project = prop([{}]);
        catarseVM.project_id(vnode.attrs.project_id);
        const lProject = catarse.loaderWithToken(models.projectDetail.getPageOptions({
            project_id: `eq.${catarseVM.project_id()}`
        }));

        lProject.load().then((data) => {
            project(data);
            loading(false);
            h.redraw();
        });

        const listProjectReportExportsVM = listProjectReportExports(vnode.attrs.project_id);

        vnode.state = {
            project,
            listProjectReportExportsVM,
            loadingProject: loading,
        };
    },
    view: function ({ state, attrs }) {

        const project = state.project;

        /** @type {Report[]} */
        const reports = state.listProjectReportExportsVM.collection();

        /** @type {boolean} */
        const loading = state.listProjectReportExportsVM.isLoading();

        /** @type {boolean} */
        const loadingProject = state.loadingProject();

        if (!loadingProject) {
            return m('div', [
                m(projectDashboardMenu, {
                    project: prop(_.first(project()))
                }),
                m('.dashboard-header',
                    m('div.w-container',
                        m('div.w-row', [
                            m('div.w-col.w-col-2'),
                            m('div.w-col.w-col-8',
                                m('div.fontweight-semibold.fontsize-larger.lineheight-looser', 'Relatórios exportados')
                            ),
                            m('div.w-col.w-col-2')
                        ])
                    )
                ),
                m('div.section.min-height-70',
                    m('div.w-container',
                        m('div.w-row', [
                            m('div.w-col.w-col-2'),
                            m('div.w-col.w-col-8', [
                                m('.card.u-radius.u-marginbottom-20.card-terciary', [
                                    m('div.fontsize-small.fontweight-semibold.u-marginbottom-20', [
                                        m('span.fa.fa-download'),
                                        ' Baixar relatórios'
                                    ]),
                                    m('div.card.u-radius', [
                                        m('strong', 'Atenção: '),
                                        'Ao realizar o download desses dados, você se compromete a armazená-los em local seguro e respeitar o direitos dos usuários conforme o que está previsto nos Termos de Uso e na política de privacidade do Catarse.'
                                    ])
                                ]),
    
                                (
                                    loading ?
                                        h.loader()
                                    :
                                        reports.map(report => 
                                            m(projectSubscriptionReportDownloadEntry, report)
                                        )
                                )
                            ]), 
                            m("div.w-col.w-col-2")
                        ])
                    )
                ),
                m('.u-marginbottom-30.u-margintop-30.w-row', [
                    m(loadMoreBtn, {
                        collection: state.listProjectReportExportsVM,
                        cssClass: '.w-col-push-4'
                    })
                ])
            ]);
        } else {
            return h.loader();
        }
    }
};

export default projectSubscriptionReportDownload;
