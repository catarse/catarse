import m from 'mithril';
import _ from 'underscore';
import h from '../h';
import FilterMain from '../c/filter-main';

const I18nScope = _.partial(h.i18nScope, 'projects.dashboard_contribution_reports');

const projectContributionReportHeader = {
    view: function({attrs}) {
        const filterBuilder = attrs.filterBuilder,
            paymentStateFilter = _.findWhere(filterBuilder, {
                label: 'payment_state'
            }),
            rewardFilter = _.findWhere(filterBuilder, {
                label: 'reward_filter'
            }),
            deliveryFilter = _.findWhere(filterBuilder, {
                label: 'delivery_filter'
            }),
            surveyFilter = _.findWhere(filterBuilder, {
                label: 'survey_filter'
            }),
            mainFilter = _.findWhere(filterBuilder, {
                component: FilterMain
            }),
            project_id = attrs.filterVM.project_id();

        rewardFilter.data.options = attrs.mapRewardsToOptions();

        return m('div', [
            m('.dashboard-header',
                    m('.w-container',
                        m('.w-row', [
                            m('.w-col.w-col-3'),
                            m('.w-col.w-col-6', [
                                m('.fontsize-larger.fontweight-semibold.lineheight-looser.u-text-center',
                                    window.I18n.t('title', I18nScope())
                                ),
                                m('.fontsize-base.u-marginbottom-20.u-text-center',
                                    window.I18n.t('subtitle_html', I18nScope())
                                ),
                                m('.u-marginbottom-60.u-text-center',
                                    m('.w-inline-block.card.fontsize-small.u-radius', [
                                        m('span.fa.fa-lightbulb-o',
                                            ''
                                        ),
                                        m.trust('&nbsp;'),
                                        m.trust(window.I18n.t('help_link', I18nScope()))
                                    ])
                                )
                            ]),
                            m('.w-col.w-col-3')
                        ])
                    )
                ),
            m('.card',
                    m('.w-container',
                        m('.w-form', [
                            m('form', {
                                onsubmit: attrs.submit
                            },
                                m('.u-margintop-20.w-row', [
                                    m('.w-col.w-col-8',
                                        m('.w-row', [
                                            m(paymentStateFilter.component, paymentStateFilter.data),
                                            m(rewardFilter.component, rewardFilter.data),
                                            m(deliveryFilter.component, deliveryFilter.data),
                                            m(surveyFilter.component, surveyFilter.data)
                                        ])
                                    ),
                                    m('.w-col.w-col-4',
                                        m('.u-margintop-20.w-row', [
                                            m(mainFilter.component, mainFilter.data)

                                        ])
                                    )
                                ])
                            )
                        ])
                    )
                )
        ]
        );
    }
};

export default projectContributionReportHeader;
