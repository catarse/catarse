import m from 'mithril';
import _ from 'underscore';
import subscriptionStatusIcon from './subscription-status-icon';
import paymentMethodIcon from './payment-method-icon';
import dashboardSubscriptionCardDetailPaymentHistory from './dashboard-subscription-card-detail-payment-history';

const dashboardSubscriptionCardDetailSubscriptionDetails = {
    view: function({attrs}) {
        const subscription = attrs.subscription,
            reward = attrs.reward,
            user = attrs.user;
            
        return m('.u-marginbottom-20.card.u-radius', 
        [
            m('.fontsize-small.fontweight-semibold.u-marginbottom-10',
                'Detalhes da assinatura'
            ),
            m('.fontsize-smaller.u-marginbottom-20', [
                m('div', [
                    m('span.fontcolor-secondary',
                      'Status: '
                     ),
                    m(subscriptionStatusIcon, {
                        subscription
                    })
                ]),
                m('div', [
                    m('span.fontcolor-secondary',
                        'Valor do pagamento mensal: '
                    ),
                    `R$${subscription.amount / 100}`
                ]),
                m('div', [
                    m('span.fontcolor-secondary',
                        'Recompensa: '
                    ), !_.isEmpty(reward) ? `R$${reward.minimum_value} - ${reward.title} - ${reward.description.substring(0, 90)}(...)` : 'Sem recompensa'
                ]),
                m('div', [
                    m('span.fontcolor-secondary',
                        'Meio de pagamento: '
                    ),
                    m(paymentMethodIcon, { subscription })
                ]),
                m('div', [
                    m('span.fontcolor-secondary',
                        'Qtde. de pagamentos confirmados: '
                    ),
                    `${subscription.paid_count} meses`
                ]),
                m('.fontsize-base.u-margintop-10', [
                    m('span.fontcolor-secondary',
                        'Total pago: '
                    ),
                    m.trust('&nbsp;'),
                    m('span.fontweight-semibold.text-success',
                        `R$${subscription.total_paid / 100}`
                    )
                ])
            ]),
            m(".divider.u-marginbottom-20"),
            m("div", [
                m(".fontsize-small.fontweight-semibold.u-marginbottom-10", "Histórico de pagamentos"),
                m(dashboardSubscriptionCardDetailPaymentHistory, { user, subscription })
            ])
        ]);
    }
};

export default dashboardSubscriptionCardDetailSubscriptionDetails;
