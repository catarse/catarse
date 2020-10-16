import m from 'mithril';
import _ from 'underscore';
import h from '../h';

const I18nScope = _.partial(h.i18nScope, 'projects.subscription_fields');

const paymentMethodIcon = {
    oninit: function(vnode) {
        const subscription = vnode.attrs.subscription;

        const paymentClass = {
            boleto: 'fa-barcode',
            credit_card: 'fa-credit-card'
        };
        vnode.state = {
            subscription,
            paymentClass
        };
    },
    view: function({state, attrs}) {
        const subscription = state.subscription,
            paymentClass = state.paymentClass;

        return m('span', [
            m(`span.fa.${paymentClass[subscription.payment_method]}`,
                ''
            ),
            window.I18n.t(subscription.payment_method, I18nScope())
        ]);
    }
};

export default paymentMethodIcon;
