import mq from 'mithril-query';
import m from 'mithril';
import subscriptionStatusIcon from '../../src/c/subscription-status-icon';
import dashboardSubscriptionCard from '../../src/c/dashboard-subscription-card';
import moment from 'moment';

describe('ShowDateFromSubscriptionTransition', () => {
    let $subscription, $output, $subscription2, $output2;

    beforeAll(() => {
        $subscription = SubscriptionMockery()[1];
        $output = mq(m(subscriptionStatusIcon, {subscription:$subscription}));

        $subscription2 = SubscriptionMockery()[2];
        $output2 = mq(m(dashboardSubscriptionCard, {subscription: $subscription2, user: {name: 'Test Name', profile_img_thumbnail: 'none'}}));
    });

    it('Should show subscription transition date', () => {
        let dateString = moment($subscription.transition_date).format('DD/MM/YYYY');
        expect($output.contains(dateString)).toBeTrue();
    });

    it ('Should show subscription last payment data date', () => {
        let lastPaymentDate = moment($subscription2.last_payment_data_created_at).format('DD/MM/YYYY');
        expect($output2.contains(lastPaymentDate)).toBeTrue();
    });
});
