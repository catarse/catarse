import m from 'mithril';
import prop from 'mithril/stream';
import { catarse } from '../api';
import _ from 'underscore';
import h from '../h';
import models from '../models';
import tooltip from '../c/tooltip';
import projectDashboardMenu from '../c/project-dashboard-menu';
import modalBox from '../c/modal-box';
import adminProjectDetailsCard from '../c/admin-project-details-card';
import onlineSuccessModalContent from '../c/online-success-modal-content';
import projectDataStats from '../c/project-data-stats';
import projectDeleteButton from '../c/project-delete-button';
import projectCancelButton from '../c/project-cancel-button';
import projectDataChart from '../c/project-data-chart';
import projectDataTable from '../c/project-data-table';
import projectReminderCount from '../c/project-reminder-count';
import projectSuccessfulOnboard from '../c/project-successful-onboard';
import projectInviteCard from '../c/project-invite-card';
import projectSuccessfullNextSteps from '../c/project-successful-next-steps';
import {
    catarseMoments
} from '../api';
import { SolidarityProjectInsightsWelcomeDraft } from './solidarity-project-insights-welcome-draft';

const I18nScope = _.partial(h.i18nScope, 'projects.insights');

const projectInsights = {
    oninit: function(vnode) {
        const filtersVM = vnode.attrs.filtersVM,
            displayModal = h.toggleProp(false, true),
            contributionsPerDay = prop([]),
            visitorsTotal = prop(0),
            visitorsPerDay = prop([]),
            loader = catarse.loaderWithToken,
            countDownToRedraw = prop(4),
            requestRedraw = () => {
                h.redraw();
            };

        if (h.paramByName('online_success') === 'true') {
            displayModal.toggle();
        }

        const processVisitors = (data) => {
            if (!_.isEmpty(data)) {
                visitorsPerDay(data);
                visitorsTotal(_.first(data).total);
                h.redraw();
            }
        };

        const lVisitorsPerDay = catarseMoments.loaderWithToken(models.projectVisitorsPerDay.getRowOptions(filtersVM.parameters()));
        lVisitorsPerDay
            .load()
            .then(data => {
                processVisitors(data);
                requestRedraw();
            });

        const lContributionsPerDay = loader(models.projectContributionsPerDay.getRowOptions(filtersVM.parameters()));
        lContributionsPerDay
            .load()
            .then(data => {
                contributionsPerDay(data);
                requestRedraw();
            });

        const contributionsPerLocationTable = [['Estado', 'Apoios', 'R$ apoiados (% do total)']];
        const buildPerLocationTable = contributions => (!_.isEmpty(contributions)) ? _.map(_.first(contributions).source, (contribution) => {
            const column = [];

            column.push(contribution.state_acronym || 'Outro/other');
            column.push(contribution.total_contributions);
            column.push([contribution.total_contributed, [// Adding row with custom comparator => read project-data-table description
                m(`input[type="hidden"][value="${contribution.total_contributed}"]`),
                'R$ ',
                h.formatNumber(contribution.total_contributed, 2, 3),
                ` (${contribution.total_on_percentage.toFixed(2)}%)`
            ]]);
            return contributionsPerLocationTable.push(column);
        }) : [];

        const lContributionsPerLocation = loader(models.projectContributionsPerLocation.getRowOptions(filtersVM.parameters()));
        lContributionsPerLocation
            .load()
            .then(data => {
                buildPerLocationTable(data);
                requestRedraw();
            });

        const contributionsPerRefTable = [[
            window.I18n.t('ref_table.header.origin', I18nScope()),
            window.I18n.t('ref_table.header.contributions', I18nScope()),
            window.I18n.t('ref_table.header.amount', I18nScope())
        ]];
        const buildPerRefTable = contributions => (!_.isEmpty(contributions)) ? _.map(_.first(contributions).source, (contribution) => {
                // Test if the string matches a word starting with ctrse_ and followed by any non-digit group of characters
                // This allows to remove any versioned referral (i.e.: ctrse_newsletter_123) while still getting ctrse_test_ref
            const re = /(ctrse_[\D]*)/,
                test = re.exec(contribution.referral_link);

            const column = [];

            if (test) {
                    // Removes last underscore if it exists
                contribution.referral_link = test[0].substr(-1) === '_' ? test[0].substr(0, test[0].length - 1) : test[0];
            }

            column.push(contribution.referral_link ? window.I18n.t(`referral.${contribution.referral_link}`, I18nScope({ defaultValue: contribution.referral_link })) : window.I18n.t('referral.others', I18nScope()));
            column.push(contribution.total);
            column.push([contribution.total_amount, [
                m(`input[type="hidden"][value="${contribution.total_contributed}"]`),
                'R$ ',
                h.formatNumber(contribution.total_amount, 2, 3),
                ` (${contribution.total_on_percentage.toFixed(2)}%)`
            ]]);
            return contributionsPerRefTable.push(column);
        }) : [];

        const lContributionsPerRef = loader(models.projectContributionsPerRef.getRowOptions(filtersVM.parameters()));
        lContributionsPerRef
            .load()
            .then(data => {
                buildPerRefTable(data);
                requestRedraw();
            });

        function isSolidarityProject() {
            const project = vnode.attrs.project;
            if (project) {
                const solidarityIntegration = (project.integrations || []).find(integration => integration.name === 'SOLIDARITY_SERVICE_FEE');
                return !!solidarityIntegration;
            } else {
                return false;
            }
        }

        vnode.state = {
            lContributionsPerRef,
            lContributionsPerLocation,
            lContributionsPerDay,
            lVisitorsPerDay,
            displayModal,
            filtersVM,
            contributionsPerDay,
            contributionsPerLocationTable,
            contributionsPerRefTable,
            visitorsPerDay,
            visitorsTotal,
            isSolidarityProject
        };
    },
    view: function({state, attrs}) {
        const project = attrs.project,
            isSolidarityProject = state.isSolidarityProject,
            buildTooltip = el => m(tooltip, {
                el,
                text: [
                    'Informa de onde vieram os apoios de seu projeto. Saiba como usar essa tabela e planejar melhor suas ações de comunicação ',
                    m(`a[href="${window.I18n.t('ref_table.help_url', I18nScope())}"][target='_blank']`, 'aqui.')
                ],
                width: 380
            });

        if (!attrs.l()) {
            project.user.name = project.user.name || 'Realizador';
        }

        return m('.project-insights', !attrs.l() ? [
            m(`.w-section.section-product.${project.mode}`),
            (project.is_owner_or_admin ? m(projectDashboardMenu, {
                project: prop(project)
            }) : ''),
            (state.displayModal() ? m(modalBox, {
                displayModal: state.displayModal,
                content: [onlineSuccessModalContent]
            }) : ''),

            m('.w-container',
                ((project.state === 'successful' || project.state === 'waiting_funds' ) && !project.has_cancelation_request) ?
                    m(projectSuccessfullNextSteps, { project: prop(project) }) : [
                        m('.w-row.u-marginbottom-40', [
                            m('.w-col.w-col-8.w-col-push-2', [
                                m('.fontweight-semibold.fontsize-larger.lineheight-looser.u-marginbottom-10.u-text-center.dashboard-header', window.I18n.t('campaign_title', I18nScope())),

                                (
                                    (project.state === 'draft' && !project.has_cancelation_request && isSolidarityProject()) ?
                                        [
                                            m(SolidarityProjectInsightsWelcomeDraft),
                                        ]
                                    :
                                        [
                                            (project.state === 'online' && !project.has_cancelation_request ? m(projectInviteCard, { project }) : ''),
                                            (project.state === 'draft' && !project.has_cancelation_request ? m(adminProjectDetailsCard, { resource: project }) : ''),
                                            m(`p.${project.state}-project-text.u-text-center.fontsize-small.lineheight-loose`,
                                                project.has_cancelation_request ?
                                                    m.trust(window.I18n.t('has_cancelation_request_explanation', I18nScope())) : [
                                                        project.mode === 'flex' && _.isNull(project.expires_at) && project.state !== 'draft' ?
                                                            m('span', [
                                                                m.trust(window.I18n.t('finish_explanation', I18nScope())),
                                                                m('a.alt-link[href="http://suporte.catarse.me/hc/pt-br/articles/213783503-tudo-sobre-Prazo-da-campanha"][target="_blank"]', window.I18n.t('know_more', I18nScope()))
                                                            ]) :
                                                            m.trust(
                                                                window.I18n.t(`campaign.${project.mode}.${project.state}`,
                                                                I18nScope({ username: project.user.name, expires_at: h.momentify(project.zone_expires_at), sent_to_analysis_at: h.momentify(project.sent_to_analysis_at) })))
                                                    ]
                                            )
                                        ]
                                )
                            ])
                        ])
                    ]),
            (project.state === 'draft' ?
               m(projectDeleteButton, { project })
            : ''),
            (project.is_published) ? [
                m('.divider'),
                m('.w-section.section-one-column.section.bg-gray.before-footer', [
                    m('.w-container', [
                        m(
                            projectDataStats,
                            { project: prop(project), visitorsTotal: state.visitorsTotal }
                        ),
                        m('.w-row', [
                            m('.w-col.w-col-12.u-text-center', {
                                style: {
                                    'min-height': '300px'
                                }
                            }, [
                                m('.fontweight-semibold.u-marginbottom-10.fontsize-large.u-text-center', [
                                    window.I18n.t('visitors_per_day_label', I18nScope())
                                ]),
                                !state.lVisitorsPerDay() ? m(projectDataChart, {
                                    collection: state.visitorsPerDay,
                                    dataKey: 'visitors',
                                    xAxis: item => h.momentify(item.day),
                                    emptyState: window.I18n.t('visitors_per_day_empty', I18nScope())
                                }) : h.loader()
                            ]),
                        ]),
                        m('.w-row', [
                            m('.w-col.w-col-12.u-text-center', {
                                style: {
                                    'min-height': '300px'
                                }
                            }, [
                                !state.lContributionsPerDay() ? m(projectDataChart, {
                                    collection: state.contributionsPerDay,
                                    label: window.I18n.t('amount_per_day_label', I18nScope()),
                                    dataKey: 'total_amount',
                                    xAxis: item => h.momentify(item.paid_at),
                                    emptyState: window.I18n.t('amount_per_day_empty', I18nScope())
                                }) : h.loader()
                            ]),
                        ]),
                        m('.w-row', [
                            m('.w-col.w-col-12.u-text-center', {
                                style: {
                                    'min-height': '300px'
                                }
                            }, [
                                !state.lContributionsPerDay() ? m(projectDataChart, {
                                    collection: state.contributionsPerDay,
                                    label: window.I18n.t('contributions_per_day_label', I18nScope()),
                                    dataKey: 'total',
                                    xAxis: item => h.momentify(item.paid_at),
                                    emptyState: window.I18n.t('contributions_per_day_empty', I18nScope())
                                }) : h.loader()
                            ]),
                        ]),
                        m('.w-row', [
                            m('.w-col.w-col-12.u-text-center', [
                                m('.project-contributions-per-ref', [
                                    m('.fontweight-semibold.u-marginbottom-10.fontsize-large.u-text-center', [
                                        window.I18n.t('ref_origin_title', I18nScope()),
                                        ' ',
                                        buildTooltip('span.fontsize-smallest.tooltip-wrapper.fa.fa-question-circle.fontcolor-secondary')
                                    ]),
                                    !state.lContributionsPerRef() ? !_.isEmpty(_.rest(state.contributionsPerRefTable)) ? m(projectDataTable, {
                                        table: state.contributionsPerRefTable,
                                        defaultSortIndex: -2
                                    }) : m('.card.u-radius.medium.u-marginbottom-60',
                                            m('.w-row.u-text-center.u-margintop-40.u-marginbottom-40',
                                                m('.w-col.w-col-8.w-col-push-2',
                                                    m('p.fontsize-base', window.I18n.t('contributions_per_ref_empty', I18nScope()))
                                                )
                                            )
                                        ) : h.loader()
                                ])
                            ]),
                        ]),
                        m('.w-row', [
                            m('.w-col.w-col-12.u-text-center', [
                                m('.project-contributions-per-ref', [
                                    m('.fontweight-semibold.u-marginbottom-10.fontsize-large.u-text-center', window.I18n.t('location_origin_title', I18nScope())),
                                    !state.lContributionsPerLocation() ? !_.isEmpty(_.rest(state.contributionsPerLocationTable)) ? m(projectDataTable, {
                                        table: state.contributionsPerLocationTable,
                                        defaultSortIndex: -2
                                    }) : m('.card.u-radius.medium.u-marginbottom-60',
                                            m('.w-row.u-text-center.u-margintop-40.u-marginbottom-40',
                                                m('.w-col.w-col-8.w-col-push-2',
                                                    m('p.fontsize-base', window.I18n.t('contributions_per_location_empty', I18nScope()))
                                                )
                                            )
                                        ) : h.loader()
                                ])
                            ]),
                        ]),
                        m('.w-row', [
                            m('.w-col.w-col-12.u-text-center', [
                                m(projectReminderCount, {
                                    resource: project
                                })
                            ]),
                        ]),
                    ])
                ]),
            (project.can_cancel ?
                m(projectCancelButton, { project })
            : '')

            ] : ''
        ] : h.loader());
    }
};

export default projectInsights;
