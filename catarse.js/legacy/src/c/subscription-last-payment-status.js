import m from 'mithril';
import _ from 'underscore';
import moment from 'moment';
import h from '../h';

const I18nScope = _.partial(h.i18nScope, 'projects.payment');

const subscriptionLastPaymentStatus = {
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
            statusClass,
            lastPaymentDate: vnode.attrs.subscription.last_payment_data_created_at,
            lastPaymentStatus: vnode.attrs.subscription.last_payment_data.status,
            lastPaymentMethod: vnode.attrs.subscription.last_payment_data.payment_method
        };
    },
    view: function({state, attrs}) {
        return m('span', [
            m(".fontsize-smaller",
                state.lastPaymentDate ? h.momentify(state.lastPaymentDate, 'DD/MM/YYYY') : ''
            ),
            m(`.fontsize-mini.lineheight-tightest.fontweight-semibold${state.statusClass[state.lastPaymentStatus]}`,
                I18n.t(`last_status.${state.lastPaymentMethod}.${state.lastPaymentStatus}`, I18nScope())
            )
        ]);
    }
};

export default subscriptionLastPaymentStatus;
