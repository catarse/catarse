import mq from 'mithril-query';
import m from 'mithril';
import dashboardSubscriptionCardDetailPaymentHistoryEntry from '../../src/c/dashboard-subscription-card-detail-payment-history-entry';

describe('DashboardSubscriptionCardDetailPaymentEntry', () => {
    let $paymentEntry, $output;

    beforeAll(() => {
        $paymentEntry = PaymentsMockery()[0];
        $output = mq(m(dashboardSubscriptionCardDetailPaymentHistoryEntry, { payment: $paymentEntry }));
    });

    it('Should show history of payment entry card brand', () => {
        const captalize = function(str) { return str.charAt(0).toUpperCase() + str.slice(1); }
        expect($output.contains(captalize($paymentEntry.payment_method_details.brand))).toBeTrue();
    });

    it('Should show history of payment entry card last digits', () => {
        expect($output.contains($paymentEntry.payment_method_details.last_digits)).toBeTrue();
    });
});