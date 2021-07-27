import m from 'mithril';
import prop from 'mithril/stream';
import _ from 'underscore';
import h from '../h';
import inlineError from './inline-error';
import projectVM from '../vms/project-vm';
import subscriptionEditModal from './subscription-edit-modal';

const I18nScope = _.partial(h.i18nScope, 'projects.contributions.edit');

const paymentPix = {
    oninit: function(vnode) {
        const vm = vnode.attrs.vm,
            isSubscriptionEdit = vnode.attrs.isSubscriptionEdit || prop(false),
            pixPaymentDate = projectVM.isSubscription() ? null : vm.getPixPaymentDate(vnode.attrs.contribution_id),
            loading = prop(false),
            error = prop(false),
            completed = prop(false),
            subscriptionEditConfirmed = prop(false),
            showSubscriptionModal = prop(false),
            isReactivation = vnode.attrs.isReactivation || prop(false);

        const buildPix = () => {
            vm.isLoading(true);
            m.redraw();

            if (isSubscriptionEdit()
                && !subscriptionEditConfirmed()
                && !isReactivation()) {
                showSubscriptionModal(true);

                return false;
            }

            vm.payPix(vnode.attrs.contribution_id, vnode.attrs.project_id, error, loading, completed);

            return false;
        };

        vnode.state = {
            vm,
            buildPix,
            pixPaymentDate,
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
        const buttonLabel = state.isSubscriptionEdit() && !attrs.isReactivation() ? window.I18n.t('subscription_edit', I18nScope()) : window.I18n.t('pay_pix', I18nScope());

        return m('.w-row',
                    m('.w-col.w-col-12',
                        m('.u-text-center.u-marginbottom-40.u-radius.card-big.card', [
                            projectVM.isSubscription() ? '' : m('.fontsize-base.fontweight-semibold.u-marginbottom-10',
                                state.pixPaymentDate() ? `Lembre-se, este QR Code vence dia ${h.momentify(state.pixPaymentDate().pix_expiration_date)}.` : 'carregando...'
                            ),
                            m('.fontsize-small.u-marginbottom-40',
                                'Clique em Gerar QR Code abaixo e você vai receber as instruções de como pagar com PIX de forma prática e instantânea direto do app de seu banco.'
                            ),
                            m('.w-row',
                                m('.w-col.w-col-8.w-col-push-2', [
                                    state.vm.isLoading() ? h.loader() : state.completed() ? '' : m('input.btn.btn-large.u-marginbottom-20', {
                                        onclick: state.buildPix,
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
                                                paymentMethod: 'pix',
                                                pay: state.buildPix
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

export default paymentPix;
