import m from 'mithril';
import prop from 'mithril/stream';
import _ from 'underscore';
import h from '../h';
import inlineError from './inline-error';
import projectVM from '../vms/project-vm';
import commonPaymentVM from '../vms/common-payment-vm';
import subscriptionEditModal from './subscription-edit-modal';

const I18nScope = _.partial(h.i18nScope, 'projects.contributions.edit');

const paymentSlip = {
    oninit: function(vnode) {
        const vm = vnode.attrs.vm,
            isSubscriptionEdit = vnode.attrs.isSubscriptionEdit || prop(false),
            slipPaymentDate = projectVM.isSubscription() ? null : vm.getSlipPaymentDate(vnode.attrs.contribution_id),
            loading = prop(false),
            error = prop(false),
            completed = prop(false),
            subscriptionEditConfirmed = prop(false),
            showSubscriptionModal = prop(false),
            isReactivation = vnode.attrs.isReactivation || prop(false);

        const buildSlip = () => {
            vm.isLoading(true);
            m.redraw();

            if (isSubscriptionEdit()
                && !subscriptionEditConfirmed()
                && !isReactivation()) {
                showSubscriptionModal(true);

                return false;
            }

            if (projectVM.isSubscription()) {
                const commonData = {
                    rewardCommonId: vnode.attrs.reward_common_id,
                    userCommonId: vnode.attrs.user_common_id,
                    projectCommonId: vnode.attrs.project_common_id,
                    amount: vnode.attrs.value * 100
                };

                if (isSubscriptionEdit()) {
                    commonPaymentVM.sendSlipPayment(vm, _.extend({}, commonData, { subscription_id: vnode.attrs.subscriptionId() }));

                    return false;
                }

                commonPaymentVM.sendSlipPayment(vm, commonData);

                return false;
            }
            vm.paySlip(vnode.attrs.contribution_id, vnode.attrs.project_id, error, loading, completed);

            return false;
        };

        vnode.state = {
            vm,
            buildSlip,
            slipPaymentDate,
            loading,
            completed,
            error,
            isSubscriptionEdit,
            showSubscriptionModal,
            subscriptionEditConfirmed,
            isReactivation
        };
    },
    view: function({state, attrs}) {
        const buttonLabel = state.isSubscriptionEdit() && !attrs.isReactivation() ? window.I18n.t('subscription_edit', I18nScope()) : window.I18n.t('pay_slip', I18nScope());

        return m('.w-row',
                    m('.w-col.w-col-12',
                        m('.u-margintop-30.u-marginbottom-60.u-radius.card-big.card', [
                            projectVM.isSubscription() ? '' : m('.fontsize-small.u-marginbottom-20',
                                state.slipPaymentDate() ? `Esse boleto bancário vence no dia ${h.momentify(state.slipPaymentDate().slip_expiration_date)}.` : 'carregando...'
                            ),
                            m('.fontsize-small.u-marginbottom-40',
                                'Ao gerar o boleto, o realizador já está contando com o seu apoio. Pague até a data de vencimento pela internet, casas lotéricas, caixas eletrônicos ou agência bancária.'
                            ),
                            m('.w-row',
                                m('.w-col.w-col-8.w-col-push-2', [
                                    state.vm.isLoading() ? h.loader() : state.completed() ? '' : m('input.btn.btn-large.u-marginbottom-20', {
                                        onclick: state.buildSlip,
                                        value: buttonLabel,
                                        type: 'submit'
                                    }),
                                    state.showSubscriptionModal()
                                        ? m(subscriptionEditModal,
                                            {
                                                attrs,
                                                vm: state.vm,
                                                showModal: state.showSubscriptionModal,
                                                confirm: state.subscriptionEditConfirmed,
                                                paymentMethod: 'boleto',
                                                pay: state.buildSlip
                                            }
                                        ) : null,
                                    !_.isEmpty(state.vm.submissionError()) ? m('.card.card-error.u-radius.zindex-10.u-marginbottom-30.fontsize-smaller', m('.u-marginbottom-10.fontweight-bold', m.trust(state.vm.submissionError()))) : '',
                                    state.error() ? m(inlineError, { message: state.error() }) : '',
                                    m('.fontsize-smallest.u-text-center.u-marginbottom-30', [
                                        'Ao apoiar, você concorda com os ',
                                        m(`a.alt-link[href=\'/${window.I18n.locale}/terms-of-use\']`,
                                            'Termos de Uso '
                                        ),
                                        'e ',
                                        m(`a.alt-link[href=\'/${window.I18n.locale}/privacy-policy\']`,
                                        'Política de Privacidade'
                                        )
                                    ])
                                ])
                    )
                        ])
            )
        );
    }
};

export default paymentSlip;
