import mq from 'mithril-query';
import m from 'mithril';
import adminSubscriptionDetail from '../../src/c/admin-subscription-detail';

describe('AdminSubscriptionNotifications', () => {

    let $output;

    beforeAll(() => {
        $output = mq(adminSubscriptionDetail, {
            item: {
                reward_id : 'reward_id'
            },
            key: 'subscription_id'
        });
    });

    describe('view', () => {

        it('Should have load more button', () => {
            expect($output.contains('Carregar mais')).toBeTrue();
        });
    });
});