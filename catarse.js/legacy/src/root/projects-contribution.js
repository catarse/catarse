import m from 'mithril';
import _ from 'underscore';
import rewardVM from '../vms/reward-vm';
import paymentVM from '../vms/payment-vm';
import projectVM from '../vms/project-vm';
import projectHeaderTitle from '../c/project-header-title';
import rewardSelectCard from '../c/reward-select-card';
import h from '../h';
import faqBox from '../c/faq-box';

const I18nScope = _.partial(h.i18nScope, 'projects.contributions');

const projectsContribution = {
    oninit: function(vnode) {

        const {
            ViewContentEvent,
        } = projectVM;
        
        projectVM.sendPageViewForCurrentProject(null, [ ViewContentEvent() ]);

        const rewards = () => _.union(
            [{
                id: null,
                description: 'Obrigado. Eu só quero ajudar o projeto.',
                minimum_value: 10,
                shipping_options: null,
                row_order: -9999999
            }],
            projectVM.rewardDetails()
        );

        const submitContribution = () => {
            const valueFloat = h.monetaryToFloat(rewardVM.contributionValue);

            if (valueFloat < rewardVM.selectedReward().minimum_value) {
                rewardVM.error(`O valor de apoio para essa recompensa deve ser de no mínimo R$${rewardVM.selectedReward().minimum_value}`);
            } else {
                rewardVM.error('');
                h.navigateTo(`/projects/${projectVM.currentProject().project_id}/contributions/fallback_create?contribution%5Breward_id%5D=${rewardVM.selectedReward().id}&contribution%5Bvalue%5D=${valueFloat}`);
            }

            return false;
        };

        projectVM.getCurrentProject();

        vnode.state = {
            project: projectVM.currentProject,
            paymentVM: paymentVM(),
            submitContribution,
            sortedRewards: () => _.sortBy(rewards(), reward => Number(reward.row_order))
        };
    },
    view: function({state, attrs}) {
        const project = state.project;

        return m('#contribution-new',
                    !_.isEmpty(project()) ? [
                        m(`.w-section.section-product.${project().mode}`),
                        m(projectHeaderTitle, {
                            project
                        }),
                        m('.w-section.header-cont-new',
                        m('.w-container',
                            m('.fontweight-semibold.lineheight-tight.text-success.fontsize-large.u-text-center-small-only', [
                                'Escolha a recompensa e o valor do apoio',
                                m.trust('&nbsp;'),
                                m('span.fontsize-small.badge.badge-success', '(parcele em até 6x)')
                            ])
                        )
                ),
                        m('.section', m('.w-container', m('.w-row', [
                            m('.w-col.w-col-8',
                        m('.w-form.back-reward-form',
                            m(`form.simple_form.new_contribution[accept-charset="UTF-8"][action="/${window.I18n.locale}/projects/${project().id}/contributions/fallback_create"][id="contribution_form"][method="get"][novalidate="novalidate"]`,
                                { onsubmit: state.submitContribution }
                            , [
                                m('input[name="utf8"][type="hidden"][value="✓"]'),
                                _.map(state.sortedRewards(), reward => m(rewardSelectCard, { reward }))
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
                                    faq: state.paymentVM.faq(project().mode),
                                    projectUserId: attrs.project_user_id
                                })
                            ])
                        ])))
                    ] : h.loader());
    }
};

export default projectsContribution;
