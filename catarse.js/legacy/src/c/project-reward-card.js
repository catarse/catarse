import m from 'mithril';
import prop from 'mithril/stream';
import _ from 'underscore';
import h from '../h';
import rewardVM from '../vms/reward-vm';
import projectVM from '../vms/project-vm';

const I18nScope = _.partial(h.i18nScope, 'projects.contributions');

const projectRewardCard = {
    oninit: function(vnode) {
        const storeKey = 'selectedReward',
            MINIMUM_VALUE = 10,
            reward = vnode.attrs.reward,
            vm = rewardVM,
            descriptionExtended = prop(0),
            selectedDestination = prop(''),
            toggleDescriptionExtended = (rewardId) => {
                if (descriptionExtended() === rewardId) {
                    descriptionExtended(0);
                } else {
                    descriptionExtended(rewardId);
                }

                return false;
            };

        const setInput = localVnode => localVnode.dom.focus();

        const selectDestination = (destination) => {
            selectedDestination(destination);

            const shippingFee = vm.shippingFeeForCurrentReward(selectedDestination)
                ? Number(vm.shippingFeeForCurrentReward(selectedDestination).value)
                : 0;
            const rewardMinValue = Number(vm.selectedReward().minimum_value);
            vm.applyMask(`${h.formatNumber(shippingFee + rewardMinValue, 2, 3)}`);
        };

        // @TODO: move submit, fee & value logic to VM
        const submitContribution = () => {
            const numberValueFloat = h.monetaryToFloat(vm.contributionValue);
            const valueFloat = _.isNaN(numberValueFloat) ? MINIMUM_VALUE : numberValueFloat;
            const shippingFee = rewardVM.hasShippingOptions(vm.selectedReward()) ? vm.shippingFeeForCurrentReward(selectedDestination) : { value: 0 };

            if (!selectedDestination() && rewardVM.hasShippingOptions(vm.selectedReward())) {
                vm.error('Por favor, selecione uma opção de frete válida.');
            } else if (valueFloat < vm.selectedReward().minimum_value + shippingFee.value) {
                vm.error(`O valor de apoio para essa recompensa deve ser de no mínimo R$${vm.selectedReward().minimum_value} ${projectVM.isSubscription(projectVM.currentProject()) ? '' : `+ frete R$${h.formatNumber(shippingFee.value, 2, 3)}`} `);
            } else {
                vm.error('');
                
                const valueUrl = window.encodeURIComponent(String(valueFloat).replace('.', ','));

                if (projectVM.isSubscription(projectVM.currentProject())) {
                    vm.contributionValue(valueFloat);
                    h.navigateTo(`/projects/${projectVM.currentProject().project_id}/subscriptions/checkout?contribution_value=${valueFloat}&reward_id=${vm.selectedReward().id}`);

                    return false;
                }

                h.navigateTo(`/projects/${projectVM.currentProject().project_id}/contributions/fallback_create?contribution%5Breward_id%5D=${vm.selectedReward().id}&contribution%5Bvalue%5D=${valueUrl}&contribution%5Bshipping_fee_id%5D=${shippingFee.id}`);
            }

            return false;
        };
        const isRewardOpened = () => vm.selectedReward() && vm.selectedReward().id === reward.id;
        const isRewardDescriptionExtended = () => descriptionExtended() === reward.id;
        const isLongDescription = () => reward.description.length > 110;
        if (h.getStoredObject(storeKey)) {
            const storedValue = h.getStoredObject(storeKey);
            const {
                value
            } = _.isNaN(storedValue) ? { value: MINIMUM_VALUE } : storedValue;

            h.removeStoredObject(storeKey);
            vm.selectedReward(reward);
            vm.contributionValue(h.applyMonetaryMask(`${value},00`));
            submitContribution();
        }

        vm.getStates();

        vnode.state = {
            setInput,
            reward,
            submitContribution,
            toggleDescriptionExtended,
            isRewardOpened,
            isLongDescription,
            isRewardDescriptionExtended,
            selectDestination,
            selectedDestination,
            error: vm.error,
            applyMask: vm.applyMask,
            selectReward: vm.selectReward,
            locationOptions: vm.locationOptions,
            contributionValue: vm.contributionValue
        };
    },
    view: function({state, attrs}) {
        // FIXME: MISSING ADJUSTS
        // - add draft admin modifications
        const reward = state.reward,
            project = attrs.project,
            isSub = projectVM.isSubscription(project);
        return m(`div[class="${h.rewardSouldOut(reward) || attrs.hasSubscription() ? 'card-gone' : `card-reward ${project.open_for_contributions ? 'clickable' : ''}`} card card-secondary u-marginbottom-10"]`, {
            onclick: h.analytics.event({
                cat: 'contribution_create',
                act: 'contribution_reward_click',
                lbl: reward.minimum_value,
                project,
                extraData: {
                    reward_id: reward.id,
                    reward_value: reward.minimum_value
                }
            }, state.selectReward(reward)),
            oncreate: state.isRewardOpened(reward) ? h.scrollTo() : Function.prototype
        }, [
            m('.u-marginbottom-20', [
                m('.fontsize-base.fontweight-semibold', `Para R$ ${h.formatNumber(reward.minimum_value)} ou mais${isSub ? ' por mês' : ''}`),
                m('.fontsize-smaller.fontweight-semibold.u-marginbottom-10', reward.title),
                (reward.uploaded_image ? m(`img[src='${reward.uploaded_image}']`) : '')
            ]),
            m(`.fontsize-smaller.reward-description${h.rewardSouldOut(reward) ? '' : '.fontcolor-secondary'}`, {
                class: state.isLongDescription()
                    ? state.isRewardOpened()
                    ? `opened ${state.isRewardDescriptionExtended() ? 'extended' : ''}`
                    : ''
                : 'opened extended'
            }, m.trust(h.simpleFormat(h.strip(reward.description)))),
            state.isLongDescription() && state.isRewardOpened() ? m('a[href="javascript:void(0);"].alt-link.fontsize-smallest.gray.link-more.u-marginbottom-20', {
                onclick: () => state.toggleDescriptionExtended(reward.id)
            }, [
                state.isRewardDescriptionExtended() ? 'menos ' : 'mais ',
                m('span.fa.fa-angle-down', {
                    class: state.isRewardDescriptionExtended() ? 'reversed' : ''
                })
            ]) : '',
            isSub ? null : m('.u-marginbottom-20.w-row', [
                m('.w-col.w-col-6', !_.isEmpty(reward.deliver_at) ? [
                    m('.fontcolor-secondary.fontsize-smallest',
                      m('span', 'Entrega prevista:')
                     ),
                    m('.fontsize-smallest',
                      h.momentify(reward.deliver_at, 'MMM/YYYY')
                     )
                ] : ''),
                m('.w-col.w-col-6', rewardVM.hasShippingOptions(reward) || reward.shipping_options === 'presential' ? [
                    m('.fontcolor-secondary.fontsize-smallest',
                      m('span',
                        'Envio:'
                       )
                     ),
                    m('.fontsize-smallest',
                      window.I18n.t(`shipping_options.${reward.shipping_options}`, I18nScope())
                     )
                ] : '')
            ]),
            (reward.maximum_contributions > 0 || reward.run_out) ? [
                (h.rewardSouldOut(reward) ? m('.u-margintop-10', [
                    m('span.badge.badge-gone.fontsize-smaller', 'Esgotada')
                ]) : m('.u-margintop-10', [
                    m('span.badge.badge-attention.fontsize-smaller', [
                        m('span.fontweight-bold', 'Limitada'),
                        project.open_for_contributions ? ` (${h.rewardRemaning(reward)} de ${reward.maximum_contributions} disponíveis)` : ''
                    ])
                ]))
            ] : '',
            m('.fontcolor-secondary.fontsize-smallest.fontweight-semibold',
              h.pluralize.apply(
                  null,
                  isSub ? [reward.paid_count, ' assinante', ' assinantes'] : [reward.paid_count, ' apoio', ' apoios'])
             ),
            reward.waiting_payment_count > 0 ? m('.maximum_contributions.in_time_to_confirm.clearfix', [
                m('.pending.fontsize-smallest.fontcolor-secondary', h.pluralize(reward.waiting_payment_count, ' apoio em prazo de confirmação', ' apoios em prazo de confirmação.'))
            ]) : '',
            project.open_for_contributions && !h.rewardSouldOut(reward) && !attrs.hasSubscription() ? [
                state.isRewardOpened() ? m('.w-form', [
                    m('form.u-margintop-30', {
                        onsubmit: state.submitContribution
                    }, [
                        m('.divider.u-marginbottom-20'),
                        rewardVM.hasShippingOptions(reward) ? m('div', [
                            m('.fontcolor-secondary.u-marginbottom-10',
                              'Local de entrega'
                             ),
                            m('select.positive.text-field.w-select', {
                                onchange: m.withAttr('value', state.selectDestination),
                                value: state.selectedDestination()
                            },
                              _.map(
                                  state.locationOptions(reward, state.selectedDestination),
                                  option => m('option',
                                              { selected: option.value === state.selectedDestination(), value: option.value },
                                      [
                                          `${option.name} `,
                                          option.value != '' ? `+R$${h.formatNumber(option.fee, 2, 3)}` : null
                                      ]
                                             )
                              )
                             )
                        ]) : '',
                        m('.fontcolor-secondary.u-marginbottom-10',
                          `Valor do apoio${isSub ? ' mensal' : ''}`
                         ),
                        m('.w-row.u-marginbottom-20', [
                            m('.w-col.w-col-3.w-col-small-3.w-col-tiny-3',
                              m('.back-reward-input-reward.placeholder', 'R$')
                             ),
                            m('.w-col.w-col-9.w-col-small-9.w-col-tiny-9',
                              m('input.w-input.back-reward-input-reward[type="tel"]', {
                                  oncreate: state.setInput,
                                  onkeyup: m.withAttr('value', state.applyMask),
                                  value: state.contributionValue()
                              })
                             )
                        ]),
                        m('input.w-button.btn.btn-medium[type="submit"][value="Continuar >"]'),
                        state.error().length > 0 ? m('.text-error', [
                            m('br'),
                            m('span.fa.fa-exclamation-triangle'),
                            ` ${state.error()}`
                        ]) : ''
                    ])
                ]) : ''
            ] : ''
        ]);
    }
};

export default projectRewardCard;
