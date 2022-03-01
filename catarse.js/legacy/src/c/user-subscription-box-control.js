import m from 'mithril';
import h from '../h';
import moment from 'moment';

const UserSubscriptionBoxControl = {
    view({state, attrs}) {
        return m('.u-marginbottom-10.u-text-center.w-col.w-col-3', this.userInteraction(attrs));
    },
    userInteraction(attrs) {
        const {
            subscription,
            displayCancelModal,
            isGeneratingSecondSlip,
            generateSecondSlip,
            showLastSubscriptionVersionEditionNextCharge,
            restoreSubscription,
        } = attrs;

        if (subscription.status === 'started') {

            if (subscription.last_payment_data.status === 'refused' && subscription.payment_method != 'boleto') {
                return [
                    m('.card-alert.u-radius.fontsize-smaller.u-marginbottom-10.fontweight-semibold',
                        m('div', [
                            m('span.fa.fa-exclamation-triangle', '.'),
                            `Seu pagamento foi recusado em ${
                                h.momentify(subscription.last_payment_data.refused_at)
                            }. Vamos tentar uma nova cobrança em ${
                                h.momentify(subscription.last_payment_data.next_retry_at)
                            }`,
                        ])
                    ),
                    m(`a.btn.btn-inline.btn-small.w-button[href='/projects/${
                            subscription.project_external_id
                        }/subscriptions/start?subscription_id=${subscription.id}${
                            subscription.reward_external_id ? `&reward_id=${subscription.reward_external_id}` : ''
                        }&subscription_status=inactive']`,
                        'Refazer pagamento'
                    ),
                    m('button.btn-link.fontsize-smallest.link-hidden-light.u-margintop-10', {
                        onclick: () => { displayCancelModal.toggle(); },
                    }, 'Cancelar assinatura'),
                ]
            } else if (subscription.payment_status === 'pending' && subscription.boleto_url && subscription.boleto_expiration_date) {
                if (moment(subscription.boleto_expiration_date).add(1, 'days').endOf('day').isBefore(Date.now())) {
                    return [
                        m('.card-alert.fontsize-smaller.fontweight-semibold.u-marginbottom-10.u-radius', [
                            m('span.fa.fa-exclamation-triangle'),
                            ` O boleto de sua assinatura venceu dia ${h.momentify(subscription.boleto_expiration_date)}`,
                        ]),
                        isGeneratingSecondSlip() ?
                            h.loader()
                        :
                            m('button.btn.btn-inline.btn-small.w-button', {
                                disabled: isGeneratingSecondSlip(),
                                onclick: generateSecondSlip,
                            }, 'Gerar segunda via'),

                        m('button.btn-link.fontsize-smallest.link-hidden-light.u-margintop-10', {
                            onclick: () => { displayCancelModal.toggle(); },
                        }, 'Cancelar assinatura'),
                    ]
                } else {
                    return [
                        m('.card-alert.fontsize-smaller.fontweight-semibold.u-marginbottom-10.u-radius', [
                            m('span.fa.fa-exclamation-triangle'),
                            ` O boleto de sua assinatura vence dia ${h.momentify(subscription.boleto_expiration_date)}`,
                        ]),
                        m(`a.btn.btn-inline.btn-small.w-button[target=_blank][href=${
                            subscription.boleto_url
                        }]`, 'Imprimir boleto'),

                        m('button.btn-link.fontsize-smallest.link-hidden-light.u-margintop-10', {
                            onclick: () => { displayCancelModal.toggle(); },
                        }, 'Cancelar assinatura'),
                    ]
                }
            } else if (subscription.payment_status === 'pending' && subscription.payment_method != 'boleto') {
                return [
                    m('.card-alert.fontsize-smaller.fontweight-semibold.u-marginbottom-10.u-radius', [
                        m('span.fa.fa-exclamation-triangle'),
                        m.trust('&nbsp;'),
                        'Aguardando confirmação do pagamento',
                    ]),
                ]
            } else {
                return '';
            }

        } else if (subscription.status === 'inactive') {

            if (subscription.payment_status === 'pending' && subscription.boleto_url && subscription.boleto_expiration_date) {
                return [
                    m('.card-alert.fontsize-smaller.fontweight-semibold.u-marginbottom-10.u-radius', [
                        m('span.fa.fa-exclamation-triangle'),
                        ` O boleto de sua assinatura vence dia ${h.momentify(subscription.boleto_expiration_date)}`,
                    ]),
                    m(`a.btn.btn-inline.btn-small.w-button[target=_blank][href=${subscription.boleto_url}]`, 'Imprimir boleto'),
                ]
            } else {
                return [
                    m('.card-alert.fontsize-smaller.fontweight-semibold.u-marginbottom-10.u-radius', [
                        m('span.fa.fa-exclamation-triangle'),
                        m.trust('&nbsp;'),
                        'Sua assinatura está inativa por falta de pagamento',
                    ]),
                    m(`a.btn.btn-inline.btn-small.w-button[target=_blank][href=/projects/${
                            subscription.project_external_id
                        }/subscriptions/start?subscription_id=${subscription.id}${
                            subscription.reward_external_id ? `&reward_id=${subscription.reward_external_id}` : ''
                        }&subscription_status=${subscription.status}]`,
                        'Assinar novamente'
                    ),
                ]
            }

        } else if (subscription.status === 'canceled' && subscription.project.state == 'online') {
            return [
                m('.card-error.fontsize-smaller.fontweight-semibold.u-marginbottom-10.u-radius', [
                    m('span.fa.fa-exclamation-triangle'),
                    m.trust('&nbsp;'),
                    ' Você cancelou sua assinatura',
                ]),

                m(`a.btn.btn-inline.btn-small.w-button[target=_blank][href=/projects/${
                        subscription.project_external_id
                    }/subscriptions/start?subscription_id=${subscription.id}${
                        subscription.reward_external_id ? `&reward_id=${subscription.reward_external_id}` : ''
                    }&subscription_status=${subscription.status}]`,
                    'Assinar novamente'
                ),
            ]

        } else if (subscription.status === 'canceling') {
            return [m('.u-radius.fontsize-smaller.u-marginbottom-10.fontweight-semibold.card-error',
                m('div', [
                    m('span.fa.fa-exclamation-triangle', ' '),
                    ` Sua assinatura será cancelada no dia ${
                        h.momentify(subscription.next_charge_at, 'DD/MM/YYYY')
                    }. Até lá, ela ainda será considerada ativa.`,
                ])),
                m('button.btn.btn-inline.btn-small.btn-terciary.w-button', {
                    onclick: restoreSubscription,
                }, 'Desfazer cancelamento')
            ]
        } else if (subscription.status === 'active') {
            if (subscription.last_payment_data.status === 'refused') {
                return [
                    m('.card-alert.u-radius.fontsize-smaller.u-marginbottom-10.fontweight-semibold',
                        m('div', [
                            m('span.fa.fa-exclamation-triangle', '.'),
                            `Seu pagamento foi recusado em ${
                                h.momentify(subscription.last_payment_data.refused_at)
                            }. Vamos tentar uma nova cobrança em ${
                                h.momentify(subscription.last_payment_data.next_retry_at)
                            }`,
                        ])
                    ),
                    m(`a.btn.btn-inline.btn-small.w-button[href='/projects/${
                            subscription.project_external_id
                        }/subscriptions/start?subscription_id=${subscription.id}${
                            subscription.reward_external_id ? `&reward_id=${subscription.reward_external_id}` : ''
                        }&subscription_status=inactive']`,
                        'Refazer pagamento'
                    ),
                    m('button.btn-link.fontsize-smallest.link-hidden-light.u-margintop-10', {
                        onclick: () => { displayCancelModal.toggle(); },
                    }, 'Cancelar assinatura'),
                ]
            } else {

                if (subscription.payment_status !== 'pending') {
                    const editHref = `/projects/${subscription.project_external_id}/subscriptions/start?${subscription.reward_external_id ? `reward_id=${subscription.reward_external_id}` : ''}&subscription_id=${subscription.id}&subscription_status=${subscription.status}`;
                    return [
                        showLastSubscriptionVersionEditionNextCharge(),
                        m('a.btn.btn-terciary.btn-inline.w-button', {
                            href: editHref,
                        }, 'Editar assinatura'),

                        m('button.btn-link.fontsize-smallest.link-hidden-light.u-margintop-10', {
                            onclick: () => { displayCancelModal.toggle(); },
                        }, 'Cancelar assinatura'),
                    ];
                } else if (subscription.payment_status === 'pending' && !!subscription.boleto_url && !!subscription.boleto_expiration_date) {
                    const isExpiredSlip = moment(subscription.boleto_expiration_date).add(1, 'days').endOf('day').isBefore(Date.now());
                    if (isExpiredSlip) {
                        return [
                            showLastSubscriptionVersionEditionNextCharge(),
                            m('.card-alert.fontsize-smaller.fontweight-semibold.u-marginbottom-10.u-radius', [
                                m('span.fa.fa-exclamation-triangle'),
                                ` O boleto de sua assinatura venceu dia ${
                                    h.momentify(subscription.boleto_expiration_date)
                                }`,
                            ]),
                            isGeneratingSecondSlip() ?
                                h.loader()
                            :
                                m('button.btn.btn-inline.btn-small.u-marginbottom-20.w-button', {
                                    disabled: isGeneratingSecondSlip( ),
                                    onclick: generateSecondSlip,
                                }, 'Gerar segunda via'),

                            m('button.btn-link.fontsize-smallest.link-hidden-light', {
                                onclick: () => { displayCancelModal.toggle(); },
                            }, 'Cancelar assinatura'),
                        ]
                    } else {
                        return [
                            showLastSubscriptionVersionEditionNextCharge(),
                            m('.card-alert.fontsize-smaller.fontweight-semibold.u-marginbottom-10.u-radius', [
                                m('span.fa.fa-exclamation-triangle'),
                                ` O boleto de sua assinatura vence dia ${h.momentify(subscription.boleto_expiration_date)}`,
                            ]),
                            m(`a.btn.btn-inline.btn-small.w-button[target=_blank][href=${
                                    subscription.boleto_url
                            }]`, 'Imprimir boleto'),
                            m('button.btn-link.fontsize-smallest.link-hidden-light.u-margintop-10', {
                                onclick: () => { displayCancelModal.toggle(); },
                            }, 'Cancelar assinatura'),
                        ]
                    }
                } else {
                    return '';
                }
            }
        } else {
            return '';
        }
    }
};


export default UserSubscriptionBoxControl;