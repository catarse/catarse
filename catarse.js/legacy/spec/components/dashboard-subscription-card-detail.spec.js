import mq from 'mithril-query';
import m from 'mithril';
import dashboardSubscriptionCardDetail from '../../src/c/dashboard-subscription-card-detail';

describe('UserAddressOnDashboardOfUserDetails', () => {
    let $userWithoutAddress, $userDetail, $subscription, $output, $output2;

    beforeAll(() => {
        $userDetail = UserDetailMockery()[0];
        $userWithoutAddress = UserDetailMockery()[1];
        $subscription = SubscriptionMockery()[0];
        $subscription = _.extend($subscription, {project_external_id: 1});
        $output = mq(m(dashboardSubscriptionCardDetail, {user:$userDetail, subscription:$subscription}));
        $output2 = mq(m(dashboardSubscriptionCardDetail, {user:$userWithoutAddress, subscription:$subscription}));
    });

    it('Should show user address street', () => {
        expect($output.contains($userDetail.address.street)).toBeTrue();
    });

	it('Should show user country', () => {
		expect($output.contains($userDetail.address.country)).toBeTrue();
    });
    
    it('Should not contain user address because it is null', () => {
        expect($output2.contains('Endereço')).toBeFalsy();
    });

    it('Should show history of payments', () => {
        expect($output.contains('Histórico de pagamento')).toBeTrue();
    });
});
