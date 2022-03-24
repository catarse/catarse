import m from 'mithril';
import _ from 'underscore';
import moment from 'moment';
import h from '../h';

const I18nScopePayment = _.partial(h.i18nScope, 'projects.payment');
const I18nScopePaymentMethod = _.partial(h.i18nScope, 'projects.payment_method');

const dashboardSubscriptionCardDetailPaymentHistoryEntry = {
    oninit: function(vnode) {
        const statusClass = {
            paid: '.text-success',
            pending: '.text-waiting',
            refused: '.text-error',
            refunded: '.text-error',
            chargedback: '.text-error',
            deleted: '.text-error',
            error: '.text-error'
        };

        vnode.state = {
            statusClass
        };
    },
    view: function({state, attrs}) {
        const
            captalize = (str) => str.charAt(0).toUpperCase() + str.slice(1),
            contributionScope = _.partial(h.i18nScope, 'users.contribution_row'),
            paymentId = attrs.payment.id,
            paymentStatus = attrs.payment.status,
            paymentAmount = attrs.payment.amount,
            paymentMethod = attrs.payment ? attrs.payment.payment_method : '',
            paymentDate = attrs.payment.created_at,
            paymentDetails = attrs.payment.payment_method_details,
            gatewayId = attrs.payment.gateway_id,
            paymentMethodText = I18n.t(`${paymentMethod}`, I18nScopePaymentMethod()),
            isSlipWithExpiration = (paymentMethod === 'boleto' &&  !_.isNull(paymentDetails.expiration_date)),
            isCreditCardWithDetails = (paymentMethod === 'credit_card' && !_.isNull(paymentDetails.brand) && !_.isNull(paymentDetails.last_digits)),
            paymentStatusText = I18n.t(`last_status.${paymentMethod}.${paymentStatus}`, I18nScopePayment()),
            paymentMethodEndText = ( isSlipWithExpiration ?
                ` com venc. ${h.momentify(paymentDetails.expiration_date, 'DD/MM')}` :
                ( isCreditCardWithDetails ?
                    ` ${captalize(paymentDetails.brand)} final ${paymentDetails.last_digits}` :
                    ''));

        return m('.fontsize-smallest.w-row',
            [
                m('div', [
                    m('span.fontcolor-secondary', h.momentify(paymentDate, 'DD/MM/YYYY')),
                    m.trust('&nbsp;&nbsp;&nbsp;&nbsp;'),
                    m(`span.fa.fa-circle${state.statusClass[paymentStatus]}`, m.trust('&nbsp;')),
                    `R$${paymentAmount / 100} ${paymentStatusText} - ${captalize(paymentMethodText)} ${paymentMethodEndText}`,
                    m.trust('&nbsp;&nbsp;&nbsp;&nbsp;'),
                    m('span.fontcolor-secondary', `( ID ${gatewayId} ) `),
                    ( paymentStatus == 'paid' ?
                        (
                            m.trust('&nbsp;&nbsp;&nbsp;&nbsp;'),
                            m(`a.alt-link.u-margintop-10[href='/projects/subscriptions/receipt/${paymentId}'][target='__blank']`,
                              `- ${window.I18n.t('show_receipt', contributionScope())}`
                        )) : ''),
                    ]

                )
            ]
        );
    }
};

export default dashboardSubscriptionCardDetailPaymentHistoryEntry;
