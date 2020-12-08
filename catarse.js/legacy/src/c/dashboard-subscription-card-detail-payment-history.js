import m from 'mithril';
import prop from 'mithril/stream';
import _ from 'underscore';
import models from '../models';
import {
    commonPayment
} from '../api';
import loadMoreBtn from './load-more-btn';
import dashboardSubscriptionCardDetailPaymentHistoryEntry from './dashboard-subscription-card-detail-payment-history-entry';
import subscriptionNextChargeDate from './subscription-next-charge-date';
import h from '../h';
import { getPaymentsListVM } from '../vms/payments-list-vm';

export default class DashboardSubscriptionCardDetailPaymentHistory {
    oninit(vnode) {
        const loadingFirstPage = prop(true);
        const errorOcurred = prop(false);
        const payments = getPaymentsListVM();
        const paymentsFilterVM = commonPayment.filtersVM({ subscription_id: 'eq' });

        paymentsFilterVM.subscription_id(vnode.attrs.subscription.id);

        payments.firstPage(paymentsFilterVM.parameters()).then(() => {
                loadingFirstPage(false);
                h.redraw();
            })
            .catch(() => {
                errorOcurred(true);
                h.redraw();
            });

        vnode.state = {
            payments,
            loadingFirstPage
        };
    }

    view({ state, attrs }) {
        const payments = state.payments.collection();
        const {
            subscription
        } = attrs;

        const last_payment = payments.length > 0 ? payments[0] : subscription.last_payment_data;

        return m(`div[m-component-name='dashboardSubscriptionCardDetailPaymentHistory']`, [
            m(subscriptionNextChargeDate, {
                subscription,
                last_payment
            }),
            _.map(payments,
                payment => m(dashboardSubscriptionCardDetailPaymentHistoryEntry, {
                    payment
                })
            ),
            m('.u-marginbottom-30.u-margintop-30.w-row', [
                m(loadMoreBtn, {
                    collection: state.payments,
                    cssClass: '.w-col-push-4'
                })
            ])
        ]);
    }
}
