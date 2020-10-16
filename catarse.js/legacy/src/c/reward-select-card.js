import m from 'mithril';
import prop from 'mithril/stream';
import _ from 'underscore';
import h from '../h';
import rewardVM from '../vms/reward-vm';
import projectVM from '../vms/project-vm';

const I18nScope = _.partial(h.i18nScope, 'projects.contributions');

const rewardSelectCard = {
    oninit: function(vnode) {
        const MINIMUM_VALUE = 10;
        const queryRewardValue = h.getParams('value');
        const setInput = localVnode => localVnode.dom.focus();
        const isSelected = currentReward => (currentReward.id == null && !rewardVM.selectedReward() && queryRewardValue) || (rewardVM.selectedReward() && currentReward.id === rewardVM.selectedReward().id);
        const selectedDestination = prop('');
        const queryRewardId = h.getParams('reward_id');
        const isEdit = prop(m.route.param('subscription_id'));
        const subscriptionStatus = m.route.param('subscription_status');
        const isReactivation = prop(subscriptionStatus === 'inactive' || subscriptionStatus === 'canceled');
        if (queryRewardValue) {
            rewardVM.setValue(h.formatNumber(Number(queryRewardValue / 100), 2, 3));
        }

        const submitContribution = (event) => {
            const numberValue = h.monetaryToFloat(rewardVM.contributionValue)
            const valueFloat = _.isNaN(numberValue) ? MINIMUM_VALUE : numberValue;
            const shippingFee = rewardVM.selectedReward() != null && rewardVM.hasShippingOptions(rewardVM.selectedReward()) ? rewardVM.shippingFeeForCurrentReward(selectedDestination) : {
                value: 0
            };

            if (!selectedDestination() && rewardVM.selectedReward() != null && rewardVM.hasShippingOptions(rewardVM.selectedReward())) {
                rewardVM.error('Por favor, selecione uma opção de frete válida.');
            } else if (valueFloat < rewardVM.selectedReward().minimum_value + shippingFee.value) {
                rewardVM.error(`O valor de apoio para essa recompensa deve ser de no mínimo R$${rewardVM.selectedReward().minimum_value} ${projectVM.isSubscription(projectVM.currentProject()) ? '' : `+ frete R$${h.formatNumber(shippingFee.value, 2, 3)}`}`);
            } else {
                rewardVM.error('');
                if (vnode.attrs.isSubscription) {
                    const currentRewardId = rewardVM.selectedReward().id;
                    h.navigateTo(`/projects/${projectVM.currentProject().project_id}/subscriptions/checkout?contribution_value=${valueFloat}${currentRewardId ? `&reward_id=${currentRewardId}` : ''}${isEdit() ? `&subscription_id=${m.route.param('subscription_id')}` : ''}${isReactivation() ? `&subscription_status=${subscriptionStatus}` : ''}`);
                } else {
                    const valueUrl = window.encodeURIComponent(String(valueFloat).replace('.', ',')); 
                    h.navigateTo(`/projects/${projectVM.currentProject().project_id}/contributions/fallback_create?contribution%5Breward_id%5D=${rewardVM.selectedReward().id}&contribution%5Bvalue%5D=${valueUrl}&contribution%5Bshipping_fee_id%5D=${shippingFee.id}`);
                }
            }

            event.stopPropagation();

            return false;
        };

        const selectDestination = (destination) => {
            selectedDestination(destination);
            const shippingFee = rewardVM.shippingFeeForCurrentReward(selectedDestination) ?
                Number(rewardVM.shippingFeeForCurrentReward(selectedDestination).value) :
                0;
            const rewardMinValue = Number(rewardVM.selectedReward().minimum_value);
            rewardVM.applyMask(`${h.formatNumber(shippingFee + rewardMinValue, 2, 3)}`);
        };

        const normalReward = (reward) => {
            if (_.isEmpty(reward)) {
                return {
                    id: null,
                    description: '',
                    minimum_value: 5,
                    shipping_options: null,
                    row_order: -999999
                };
            }

            return reward;
        };


        if (vnode.attrs.reward.id === Number(queryRewardId)) {
            rewardVM.selectReward(vnode.attrs.reward).call();
        }

        rewardVM.getStates();

        vnode.state = {
            normalReward,
            isSelected,
            setInput,
            submitContribution,
            selectDestination,
            selectedDestination,
            locationOptions: rewardVM.locationOptions,
            states: rewardVM.getStates(),
            selectReward: rewardVM.selectReward,
            error: rewardVM.error,
            applyMask: rewardVM.applyMask,
            contributionValue: rewardVM.contributionValue
        };
    },
    view: function({state, attrs}) {
        const reward = state.normalReward(attrs.reward);

        return (h.rewardSouldOut(reward) ? m('') : m('span.radio.w-radio.w-clearfix.back-reward-radio-reward', {
            class: state.isSelected(reward) ? 'selected' : '',
            onclick: state.selectReward(reward)
        },
            m(`label[for="contribution_reward_id_${reward.id}"]`, [
                m(`input.radio_buttons.optional.w-input.text-field.w-radio-input.back-reward-radio-button[id="contribution_reward_id_${reward.id}"][type="radio"][value="${reward.id}"]`, {
                    checked: state.isSelected(reward),
                    name: 'contribution[reward_id]'
                }),
                m(`label.w-form-label.fontsize-base.fontweight-semibold.u-marginbottom-10[for="contribution_reward_${reward.id}"]`, !reward.id ? 'Apoiar sem recompensa' :
                    `R$ ${h.formatNumber(reward.minimum_value)} ou mais${attrs.isSubscription ? ' por mês' : ''}`
                ), !state.isSelected(reward) ? '' : m('.w-row.back-reward-money', [
                    rewardVM.hasShippingOptions(reward) ?
                    m('.w-sub-col.w-col.w-col-4', [
                        m('.fontcolor-secondary.u-marginbottom-10',
                            'Local de entrega'
                        ),
                        m('select.positive.text-field.w-select', {
                            onchange: m.withAttr('value', state.selectDestination)
                        },
                            _.map(state.locationOptions(reward, state.selectedDestination),
                                option => m('option', {
                                    value: option.value
                                }, [
                                    `${option.name} `,
                                    option.value != '' ? `+R$${h.formatNumber(option.fee, 2, 3)}` : null
                                ])
                            )
                        )
                    ]) : '',
                    m('.w-sub-col.w-col.w-clearfix', {
                        class: rewardVM.hasShippingOptions(reward) ?
                            'w-col-4' : 'w-col-8'
                    }, [
                        m('.fontcolor-secondary.u-marginbottom-10', `Valor do apoio${attrs.isSubscription ? ' mensal' : ''}`),
                        m('.w-row.u-marginbottom-20', [
                            m('.w-col.w-col-3.w-col-small-3.w-col-tiny-3',
                                m('.back-reward-input-reward.medium.placeholder',
                                    'R$'
                                )
                            ),
                            m('.w-col.w-col-9.w-col-small-9.w-col-tiny-9',
                                m('input.back-reward-input-reward.medium.w-input', {
                                    autocomplete: 'off',
                                    min: reward.minimum_value,
                                    placeholder: reward.minimum_value,
                                    type: 'tel',
                                    oncreate: state.setInput,
                                    onkeyup: m.withAttr('value', state.applyMask),
                                    value: state.contributionValue()
                                })
                            )
                        ]),
                        m('.fontsize-smaller.text-error.u-marginbottom-20.w-hidden', [
                            m('span.fa.fa-exclamation-triangle'),
                            ' O valor do apoio está incorreto'
                        ])
                    ]),
                    m('.submit-form.w-col.w-col-4',
                        m('button.btn.btn-medium.u-margintop-30', {
                            onclick: state.submitContribution
                        }, [
                            'Continuar  ',
                            m('span.fa.fa-chevron-right')
                        ])
                    )
                ]),
                state.error().length > 0 && state.isSelected(reward) ? m('.text-error', [
                    m('br'),
                    m('span.fa.fa-exclamation-triangle'),
                    ` ${state.error()}`
                ]) : '',
                m('.fontsize-smaller.fontweight-semibold',
                    reward.title
                ),
                m('.back-reward-reward-description', [
                    (
                        reward.uploaded_image ? 
                            (
                                m("div.u-marginbottom-20.w-row", [
                                    m("div.w-col.w-col-8", 
                                        m(`img[src='${reward.uploaded_image}'][alt='']`)
                                    ),
                                    m("div.w-col.w-col-4")
                                ])
                            )
                        :
                            ''
                    ),
                    m('.fontsize-smaller.u-marginbottom-10.fontcolor-secondary', reward.description),
                    m('.u-marginbottom-20.w-row', [!reward.deliver_at || attrs.isSubscription ? '' : m('.w-col.w-col-6', [
                        m('.fontsize-smallest.fontcolor-secondary', 'Entrega Prevista:'),
                        m('.fontsize-smallest', h.momentify(reward.deliver_at, 'MMM/YYYY'))
                    ]),
                        attrs.isSubscription || (!rewardVM.hasShippingOptions(reward) && reward.shipping_options !== 'presential') ? '' : m('.w-col.w-col-6', [
                            m('.fontsize-smallest.fontcolor-secondary', 'Envio:'),
                            m('.fontsize-smallest', window.I18n.t(`shipping_options.${reward.shipping_options}`, I18nScope()))
                        ])
                    ])
                ])
            ])
        ));
    }
};

export default rewardSelectCard;
