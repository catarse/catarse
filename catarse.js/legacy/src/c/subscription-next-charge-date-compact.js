import m from 'mithril';
import moment from 'moment';

const subscriptionNextChargeDateCompact = {

    view: function({
        state,
        attrs
    }) {

        const {
            subscription,
        } = attrs;

        const {
            status,
            next_charge_at
        } = subscription;

        if ((status === 'active' || status === 'started') && !!next_charge_at) {
            return m('div.fontsize-smallest.fontweight-semibold.fontcolor-secondary.u-marginbottom-10', [
                'Próx. cobrança:',
                m.trust('&nbsp;'),
                moment(next_charge_at).format('DD/MM/YYYY')
            ]);
        } else {
            return m('span[style="display:none"]');
        }
    }
};

export default subscriptionNextChargeDateCompact;
