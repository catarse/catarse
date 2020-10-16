import m from 'mithril';
import moment from 'moment';
import h from '../h';

const subscriptionNextChargeDateMethodInfo = {
    view: function({attrs}) {
        const payment_method = attrs.payment_method;
        const payment_method_details = attrs.payment_method_details;
        const next_charge_at = attrs.next_charge_at;

        const hasPaymentMethodDetails = payment_method_details && payment_method_details.last_digits && payment_method_details.brand;

        if (payment_method === 'boleto') {
            return `${h.momentify(next_charge_at, 'DD/MM/YYYY')} - Boleto`;
        } else if (hasPaymentMethodDetails) {
            const {
                last_digits,
                brand
            } = payment_method_details;

            return `${h.momentify(next_charge_at, 'DD/MM/YYYY')} - Cartão ${brand} final ${last_digits}`;
        } else {
            return h.loader();
        }
    }
};

export default subscriptionNextChargeDateMethodInfo;
