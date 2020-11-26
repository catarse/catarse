import m from 'mithril';
import prop from 'mithril/stream';
import moment, { min } from 'moment';
import _ from 'underscore';
import { catarse, catarseMoments, commonAnalytics } from '../api';
import models from '../models';
import h from '../h';
import projectDashboardMenu from '../c/project-dashboard-menu';
import projectDataChart from '../c/project-data-chart';
import projectInviteCard from '../c/project-invite-card';
import subscriptionsPerMonthTable from '../c/subscriptions-per-month-table';
import projectGoalsBoxDashboard from './project-goals-box-dashboard';
import insightsInfoBox from './insights-info-box';
import projectGoalsVM from '../vms/project-goals-vm';
import subscriptionVM from '../vms/subscription-vm';
import userVM from '../vms/user-vm';

const I18nScope = _.partial(h.i18nScope, 'projects.insights');

const projectInsightsSub = {
    oninit: function(vnode) {
        const filtersVM = vnode.attrs.filtersVM,
            visitorsTotal = prop(0),
            visitorLoader = catarseMoments.loaderWithToken,
            loader = commonAnalytics.loaderWithToken,
            visitorsPerDay = prop([]);
        const insightResumeDataLastWeek = prop({
            mean_amount : 0, 
            subscriptions_count : 0, 
            total_amount : 0
        });
        const insightResumeDataLast2Week = prop({
            mean_amount : 0, 
            subscriptions_count : 0, 
            total_amount : 0
        });
        const subscriptionsPerDay = prop([]);
        const weekTransitions = prop([]);
        const lastWeekTransitions = prop([]);
        const subscriptionsPerMonth = prop([]);
        const isSubscriptionsPerMonthLoaded = prop(false);
        const balanceData = prop(null);
        const subVM = commonAnalytics.filtersVM({
            project_id: 'eq',
        });
        const processVisitors = data => {
            if (!_.isEmpty(data)) {
                visitorsPerDay(data);
                visitorsTotal(_.first(data).total);
            }
        };
        const requestRedraw = h.createRequestAutoRedraw(
            subscriptionsPerDay,
            weekTransitions,
            lastWeekTransitions,
            subscriptionsPerMonth,
            isSubscriptionsPerMonthLoaded,
            balanceData
        );

        subscriptionVM
            .getNewSubscriptionsInsightsFromLastWeek(vnode.attrs.project.common_id)
            .then(insights => {
                insightResumeDataLastWeek(insights);
                h.redraw();
            });

        subscriptionVM
            .getNewSubscriptionsInsightsFromLast2Week(vnode.attrs.project.common_id)
            .then(insightsLast2Weeks => {
                insightResumeDataLast2Week(insightsLast2Weeks);
                h.redraw();
            });

        subVM.project_id(vnode.attrs.project.common_id);
        const lVisitorsPerDay = visitorLoader(models.projectVisitorsPerDay.getRowOptions(filtersVM.parameters()));
        lVisitorsPerDay
            .load()
            .then(processVisitors)
            .then(requestRedraw);

        const lSubscriptionsPerDay = loader(models.projectSubscriptionsPerDay.getRowOptions(subVM.parameters()));
        lSubscriptionsPerDay
            .load()
            .then(subscriptionsPerDay)
            .then(requestRedraw);

        subscriptionVM
            .getSubscriptionTransitions(vnode.attrs.project.common_id, ['inactive', 'canceled'], 'active', moment().utc().subtract(1, 'weeks').format(), moment().utc().format())
            .then(weekTransitions)
            .then(requestRedraw);

        subscriptionVM
            .getSubscriptionTransitions(
                vnode.attrs.project.common_id,
                ['inactive', 'canceled'],
                'active',
                moment()
                    .utc()
                    .subtract(2, 'weeks')
                    .format(),
                moment()
                    .utc()
                    .subtract(1, 'weeks')
                    .format()
            )
            .then(lastWeekTransitions)
            .then(requestRedraw);

        subscriptionVM.getSubscriptionsPerMonth(vnode.attrs.project.common_id).then(subscriptions => {
            subscriptionsPerMonth(subscriptions);
            isSubscriptionsPerMonthLoaded(true);
            requestRedraw();
        });

        projectGoalsVM.fetchGoals(filtersVM.project_id());
        const balanceLoader = userVM.getUserBalance(vnode.attrs.project.user_id);
        balanceLoader.then(balanceData).then(requestRedraw);

        vnode.state = {
            subscriptionsPerMonth,
            weekTransitions,
            lastWeekTransitions,
            projectGoalsVM,
            lVisitorsPerDay,
            lSubscriptionsPerDay,
            subscriptionsPerDay,
            visitorsTotal,
            visitorsPerDay,
            balanceLoader,
            balanceData,
            isSubscriptionsPerMonthLoaded,
            insightResumeDataLastWeek,
            insightResumeDataLast2Week
        };
    },
    view: function({state, attrs}) {
        const project = attrs.project,
            subscribersDetails = attrs.subscribersDetails,
            balanceData = (state.balanceData() && !_.isNull(_.first(state.balanceData())) ? _.first(state.balanceData()) : null);
        
        const atLeastZero = num => (num === null || isNaN(num)) ? 0 : Math.max(0, num);
        const averageAmount = atLeastZero(state.insightResumeDataLastWeek().mean_amount) / 100.0;
        const totalAmountFromLastWeek = atLeastZero(state.insightResumeDataLastWeek().total_amount) / 100.0;
        const totalAmountFromLast2Week = atLeastZero(state.insightResumeDataLast2Week().total_amount) / 100.0;

        return m('.project-insights', !attrs.l() ? [
            m(`.w-section.section-product.${project.mode}`),
            (project.is_owner_or_admin ? m(projectDashboardMenu, {
                project: prop(project)
            }) : ''),
            m('.dashboard-header.section-one-column', [
                m('.u-marginbottom-30.u-text-center', [
                    m('.fontsize-larger.fontweight-semibold',
                        `Olá, ${project.user.public_name || project.user.name}!`
                    ),
                    m('.fontsize-smaller',
                        `Este é o retrato de sua campanha hoje, ${moment().format('DD [de] MMMM [de] YYYY')}`
                    )
                ]),
                m('.w-container', [
                    m('.flex-row.u-marginbottom-40.u-text-center-small-only', [
                        subscribersDetails && !_.isEmpty(state.projectGoalsVM.goalsData()) ?
                        m(projectGoalsBoxDashboard, {
                            goalDetails: state.projectGoalsVM.goalsData,
                            amount: subscribersDetails.amount_paid_for_valid_period
                        }) : '',
                        m('.card.card-terciary.flex-column.u-marginbottom-10.u-radius', [
                            m('.fontsize-small.u-marginbottom-10',
                                'Assinaturas ativas'
                            ),
                            m('.fontsize-largest.fontweight-semibold',
                                subscribersDetails.total_subscriptions
                            )
                        ]),
                        m('.card.card-terciary.flex-column.u-marginbottom-10.u-radius', [
                            m('.fontsize-small.u-marginbottom-10',
                                'Receita Mensal'
                            ),
                            m('.fontsize-largest.fontweight-semibold.u-marginbottom-10',
                                `R$${h.formatNumber(subscribersDetails.amount_paid_for_valid_period, 2, 3)}`
                            ),
                            m('.fontsize-mini.fontcolor-secondary.lineheight-tighter',
                                'Com base nas assinaturas ativas que você possui hoje (taxas já descontadas).'
                            )
                        ]),
                        m('.card.flex-column.u-marginbottom-10.u-radius', [
                            m('.fontsize-small.u-marginbottom-10', [
                                'Saldo',
                                m.trust('&nbsp;'),
                                ' ',
                                m(`a.btn-inline.btn-terciary.fontsize-smallest.u-radius[href='/users/${project.user_id}/edit#balance'][target='_self']`,
                                    'Sacar'
                                )
                            ]),
                            m('.fontsize-largest.fontweight-semibold.text-success.u-marginbottom-10',
                                (balanceData && balanceData.amount ? `R$${h.formatNumber(balanceData.amount, 2, 3)}` : '')
                            ),
                            m('.fontsize-mini.fontcolor-secondary.lineheight-tighter',
                                'O saldo demora até 20 mins após o pagamento para ser atualizado.'
                            )
                        ])
                    ]),
                    (project.state === 'online' && !project.has_cancelation_request ? m('.w-container.u-marginbottom-60', m(projectInviteCard, {
                        project
                    })) : ''),

                    m('.u-marginbottom-30', [
                        m('.flex-row.u-marginbottom-40.u-text-center-small-only', [
                            m('.flex-column.card.u-radius.u-marginbottom-10', [
                                m('div',
                                    'Receita média por assinatura'
                                ),
                                m('.fontsize-smallest.fontcolor-secondary.lineheight-tighter',
                                    `em ${moment().format('DD/MM/YYYY')}`
                                ),
                                m('.fontsize-largest.fontweight-semibold',
                                    `R$${averageAmount ? `${h.formatNumber(averageAmount, 2, 3)}` : '--'}`
                                )

                            ]),
                            m(insightsInfoBox, {
                                label: 'Novos Assinantes',
                                info: state.insightResumeDataLastWeek().subscriptions_count,
                                newCount: state.insightResumeDataLastWeek().subscriptions_count,
                                oldCount: state.insightResumeDataLast2Week().subscriptions_count
                            }),
                            m(insightsInfoBox, {
                                label: 'Nova receita',
                                info: `R$${h.formatNumber(totalAmountFromLastWeek, 2, 3)}`,
                                newCount: totalAmountFromLastWeek,
                                oldCount: totalAmountFromLast2Week
                            })
                        ]),
                        m(".fontsize-large.fontweight-semibold.u-marginbottom-10.u-text-center[id='origem']", [
                            window.I18n.t('visitors_per_day_label', I18nScope())
                        ]),
                        m('.u-text-center.fontsize-smaller.fontcolor-secondary.lineheight-tighter.u-marginbottom-20', [
                            window.I18n.t('last_30_days_indication', I18nScope())
                        ])
                    ]), !state.lVisitorsPerDay() ? m(projectDataChart, {
                        collection: state.visitorsPerDay,
                        dataKey: 'visitors',
                        limitDataset: 30,
                        xAxis: item => h.momentify(item.day),
                        emptyState: window.I18n.t('visitors_per_day_empty', I18nScope())
                    }) : h.loader(),

                    m('.u-text-center', {
                        style: {
                            'min-height': '300px'
                        }
                    }, [!state.lSubscriptionsPerDay() ? m(projectDataChart, {
                        collection: state.subscriptionsPerDay,
                        label: window.I18n.t('amount_per_day_label_sub', I18nScope()),
                        subLabel: window.I18n.t('paid_date_indication', I18nScope()),
                        dataKey: 'total_amount',
                        xAxis: item => h.momentify(item.paid_at),
                        emptyState: m.trust(window.I18n.t('amount_per_day_empty_sub', I18nScope()))
                    }) : h.loader()]),
                    m('.u-text-center', {
                        style: {
                            'min-height': '300px'
                        }
                    }, [!state.lSubscriptionsPerDay() ? m(projectDataChart, {
                        collection: state.subscriptionsPerDay,
                        label: window.I18n.t('contributions_per_day_label_sub', I18nScope()),
                        subLabel: window.I18n.t('paid_date_indication', I18nScope()),
                        dataKey: 'total',
                        xAxis: item => h.momentify(item.paid_at),
                        emptyState: m.trust(window.I18n.t('contributions_per_day_empty_sub', I18nScope()))
                    }) : h.loader()]),
                    (state.isSubscriptionsPerMonthLoaded() ?
                        m(subscriptionsPerMonthTable, { data: state.subscriptionsPerMonth() }) : h.loader())
                          ]),
                      ]),
                  ]
                : h.loader()
        );
    },
};

export default projectInsightsSub;
