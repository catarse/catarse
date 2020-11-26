import m from 'mithril';
import prop from 'mithril/stream';
import _ from 'underscore';
import rewardVM from '../vms/reward-vm';
import paymentVM from '../vms/payment-vm';
import projectVM from '../vms/project-vm';
import projectHeaderTitle from '../c/project-header-title';
import rewardSelectCard from '../c/reward-select-card';
import h from '../h';
import faqBox from '../c/faq-box';

const I18nScope = _.partial(h.i18nScope, 'projects.contributions');

const projectsSubscriptionContribution = {
    oninit: function(vnode) {
        
        const {
            ViewContentEvent,
        } = projectVM;
        
        projectVM.sendPageViewForCurrentProject(null, [ ViewContentEvent() ]);
        
        const rewards = () => _.union(
            [{
                id: null,
                description: '',
                minimum_value: 5,
                shipping_options: null,
                row_order: -9999999
            }],
            projectVM.rewardDetails()
        );

        const isEdit = prop(m.route.param('subscription_id'));
        const subscriptionStatus = m.route.param('subscription_status');
        const isReactivation = prop(subscriptionStatus === 'inactive' || subscriptionStatus === 'canceled');

        const submitContribution = (event) => {
            const valueFloat = h.monetaryToFloat(rewardVM.contributionValue);
            const currentRewardId = rewardVM.selectedReward().id;

            if (valueFloat < rewardVM.selectedReward().minimum_value) {
                rewardVM.error(`O valor de apoio para essa recompensa deve ser de no mínimo R$${rewardVM.selectedReward().minimum_value}`);
            } else {
                rewardVM.error('');
                h.navigateTo(`/projects/${projectVM.currentProject().project_id}/subscriptions/checkout?contribution_value=${valueFloat}${currentRewardId ? `&reward_id=${currentRewardId}` : ''}${isEdit() ? `&subscription_id=${m.route.param('subscription_id')}` : ''}${isReactivation() ? `&subscription_status=${subscriptionStatus}` : ''}`);
            }
        };

        projectVM.getCurrentProject();

        vnode.state = {
            isEdit,
            isReactivation,
            project: projectVM.currentProject,
            paymentVM: paymentVM(),
            submitContribution,
            sortedRewards: () => _.sortBy(rewards(), reward => Number(reward.row_order))
        };
    },
    view: function({state, attrs}) {
        const project = state.project;
        if (_.isEmpty(project())) {
            return h.loader();
        }
        const faq = state.paymentVM.faq(
            state.isReactivation()
                ? `${project().mode}_reactivate`
                : state.isEdit()
                    ? `${project().mode}_edit`
                    : project().mode);

        return m('#contribution-new', !_.isEmpty(project()) ? [
            m(`.w-section.section-product.${project().mode}`),
            m('.dark.project-main-container',
                m(projectHeaderTitle, {
                    project
                })
            ),
            m('.w-section.header-cont-new',
                m('.w-container',
                    state.isReactivation()
                        ? [m('.fontweight-semibold.lineheight-tight.text-success.fontsize-large.u-text-center-small-only', window.I18n.t('subscription_reactivation_title', I18nScope())),
                            m('.fontsize-base', window.I18n.t('subscription_edit_subtitle', I18nScope()))]
                        : state.isEdit()
                            ? [m('.fontweight-semibold.lineheight-tight.text-success.fontsize-large.u-text-center-small-only', window.I18n.t('subscription_edit_title', I18nScope())),
                                m('.fontsize-base', window.I18n.t('subscription_edit_subtitle', I18nScope()))]
                            : m('.fontweight-semibold.lineheight-tight.text-success.fontsize-large.u-text-center-small-only', window.I18n.t('subscription_start_title', I18nScope()))
                )
            ),
            m('.section', m('.w-container', m('.w-row', [
                m('.w-col.w-col-8',
                    m('.w-form.back-reward-form',
                        m(`form.simple_form.new_contribution[accept-charset="UTF-8"][action="/projects/${project().id}/subscriptions/checkout"][id="contribution_form"][method="get"]`, {
                            onsubmit: state.submitContribution
                        }, [
                            _.map(state.sortedRewards(), reward => m(rewardSelectCard, {
                                reward,
                                isSubscription: projectVM.isSubscription(project),
                                isReactivation: state.isReactivation
                            }))
                        ])
                    )
                ),
                m('.w-col.w-col-4', [
                    m('.card.u-marginbottom-20.u-radius.w-hidden-small.w-hidden-tiny', [
                        m('.fontsize-small.fontweight-semibold', window.I18n.t('contribution_warning.title', I18nScope())),
                        m('.fontsize-smaller.u-marginbottom-10', window.I18n.t('contribution_warning.subtitle', I18nScope())),
                        m('.fontcolor-secondary.fontsize-smallest.u-marginbottom-10', window.I18n.t('contribution_warning.info', I18nScope())),
                        m(`a.alt-link.fontsize-smallest[target="__blank"][href="${window.I18n.t('contribution_warning.link', I18nScope())}"]`, window.I18n.t('contribution_warning.link_label', I18nScope()))
                    ]),
                    m(faqBox, {
                        mode: project().mode,
                        vm: state.paymentVM,
                        faq,
                        projectUserId: attrs.project_user_id,
                        isEdit: state.isEdit(),
                        isReactivate: state.isReactivation()
                    })
                ])
            ])))
        ] : h.loader());
    }
};

export default projectsSubscriptionContribution;
