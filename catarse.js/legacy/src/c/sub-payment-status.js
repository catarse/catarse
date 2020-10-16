import m from 'mithril';
import h from '../h';
import paymentMethodIcon from './payment-method-icon';
import subscriptionStatusIcon from './subscription-status-icon';

const subPaymentStatus = {
    view: function({attrs}) {
        const subscription = attrs.item;
        return m('.w-row.admin-contribution', [
            m('div',
                m(subscriptionStatusIcon, {
                    subscription
                })),
            m('div',

                m(paymentMethodIcon, {
                    subscription
                })
            )
        ]);
    }
};

export default subPaymentStatus;
