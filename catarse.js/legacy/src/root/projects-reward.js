import m from 'mithril';
import _ from 'underscore';
import h from '../h';
import projectVM from '../vms/project-vm';
import rewardVM from '../vms/reward-vm';
import faqBox from '../c/faq-box';

const projectsReward = {
    oninit: function(vnode) {
        const vm = rewardVM,
            selectedReward = vm.selectedReward,
            selectReward = vm.selectReward,
            rewards = vm.rewards(),
            mode = projectVM.currentProject().mode,
            faq = window.I18n.translations[window.I18n.currentLocale()].projects.faq[mode];

        // TODO unify projectsReward and project-reward-list reward submission. fix routing issue.
        const submitContribution = () => {
            const valueFloat = h.monetaryToFloat(vm.contributionValue);

            if (valueFloat < vm.selectedReward().minimum_value) {
                vm.error(`O valor de apoio para essa recompensa deve ser de no mínimo R$${vm.selectedReward().minimum_value}`);
            } else if (!h.getUser()) {
				const storeKey = 'selectedReward';
                h.storeObject(storeKey, { value: valueFloat, reward: vm.selectedReward() });

                return h.navigateToDevise(`/${projectVM.currentProject().permalink}`);
            } else {
                vm.error('');
                vm.contributionValue(valueFloat);
                m.route(`/projects/${projectVM.currentproject().project_id}/payment`, {
                    project_user_id: projectVM.currentProject().user_id
                });
            }

            return false;
        };

        const isSelected = reward => reward.id === selectedReward().id;

        if (_.first(rewards).id !== vm.noReward.id) {
            rewards.unshift(vm.noReward);
        }

        vnode.state = {
            rewards,
            project: projectVM.currentProject,
            contributionValue: vm.contributionValue,
            submitContribution,
            applyMask: vm.applyMask,
            error: vm.error,
            isSelected,
            selectedReward,
            selectReward,
            faq
        };
    },
    view: function({state, attrs}) {
        const project = state.project;

        return m('#project-rewards', [
            m('.w-section.page-header.u-text-center', [
                m('.w-container', [
                    m('h1.fontsize-larger.fontweight-semibold.project-name[itemprop="name"]', h.selfOrEmpty(project().name || project().project_name)),
                    m('h2.fontsize-base.lineheight-looser[itemprop="author"]', [
                        'por ',
                        project().user ? project().user.name : project().owner_name ? project().owner_name : ''
                    ])
                ])
            ]),
            m('.w-section.header-cont-new',
                    m('.w-container',
                        m('.fontweight-semibold.lineheight-tight.text-success.fontsize-large.u-text-center-small-only', [
                            'Escolha a recompensa e o valor do apoio',
                            m.trust('&nbsp;'),
                            m('span.fontsize-small.badge.badge-success', '(parcele em até 6x)')
                        ])
                    )
                ),
            m('.section[id=\'new-contribution\']',
                    m('.w-container',
                        m('.w-row',
                            [
                                m('.w-col.w-col-8',
                                    m('.w-form.back-reward-form',
                                        m('form.simple_form.new_contribution', {
                                            onsubmit: state.submitContribution
                                        }, _.map(state.rewards, (reward, index) => {
                                            const isSelected = state.isSelected(reward),
                                                monetaryMinimum = h.applyMonetaryMask(reward.minimum_value);

                                            return m('span.radio.w-radio.w-clearfix.back-reward-radio-reward', {
                                                class: isSelected ? 'selected' : '',
                                                onclick: state.selectReward(reward),
                                                key: index
                                            }, m(`label[for='contribution_reward_id_${reward.id}']`,
                                                [
                                                    m(`input.radio_buttons.optional.w-input.text-field.w-radio-input.back-reward-radio-button[id='contribution_reward_id_${reward.id}'][name='contribution[reward_id]'][type='radio'][value='${reward.id}']`, {
                                                        checked: !!isSelected,
                                                    }),
                                                    m(`label.w-form-label.fontsize-base.fontweight-semibold.u-marginbottom-10[for='contribution_reward_${reward.id}']`,
                                                                    reward.id === -1 ? 'Não quero recompensa' : `R$ ${reward.minimum_value} ou mais`
                                                                ),
                                                    isSelected ? m('.w-row.back-reward-money',
                                                        [
                                                            m('.w-col.w-col-8.w-col-small-8.w-col-tiny-8.w-sub-col-middle.w-clearfix',
                                                                [
                                                                    m('.w-row',
                                                                        [
                                                                            m('.w-col.w-col-3.w-col-small-3.w-col-tiny-3',
                                                                                            m('.back-reward-input-reward.placeholder',
                                                                                                'R$'
                                                                                            )
                                                                                        ),
                                                                            m('.w-col.w-col-9.w-col-small-9.w-col-tiny-9',
                                                                                            m('input.user-reward-value.back-reward-input-reward[autocomplete=\'off\'][type=\'tel\']', {
                                                                                                class: state.error() ? 'error' : '',
                                                                                                min: monetaryMinimum,
                                                                                                placeholder: monetaryMinimum,
                                                                                                onkeyup: m.withAttr('value', state.applyMask),
                                                                                                value: state.contributionValue()
                                                                                            }
                                                                                            )
                                                                                        )
                                                                        ]
                                                                                ),
                                                                    state.error().length > 0 ? m('.text-error', [
                                                                        m('br'),
                                                                        m('span.fa.fa-exclamation-triangle'),
                                                                        ` ${state.error()}`
                                                                    ]) : ''
                                                                ]
                                                                        ),
                                                            m('.submit-form.w-col.w-col-4.w-col-small-4.w-col-tiny-4',
                                                                            m('button.btn.btn-large', [
                                                                                'Continuar  ',
                                                                                m('span.fa.fa-chevron-right')
                                                                            ])
                                                                        )
                                                        ]
                                                                ) : '',
                                                    m('.back-reward-reward-description',
                                                        [
                                                            m('.fontsize-smaller.u-marginbottom-10', reward.description),
                                                            reward.deliver_at ? m('.fontsize-smallest.fontcolor-secondary', `Estimativa de entrega: ${h.momentify(reward.deliver_at, 'MMM/YYYY')}`) : ''
                                                        ]
                                                                )
                                                ]
                                                        )
                                                    ); // End map return
                                        })
                                    )
                                )
                            ),
                                m('.w-col.w-col-4', m(faqBox, { mode: state.project().mode, faq: state.faq }))
                            ]
                    )
                )
            )
        ]);
    }
};

export default projectsReward;
