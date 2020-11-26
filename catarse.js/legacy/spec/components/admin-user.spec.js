import mq from 'mithril-query';
import adminUser from '../../src/c/admin-user';

describe('AdminUser', () => {
    let item, $output;

    describe('view', () => {
        beforeAll(() => {
            item = ContributionDetailMockery(1)[0];
            $output = mq(adminUser, {
                item: item
            });
        });

        it('should build an item from an item describer', () => {
            expect($output.has('.user-avatar')).toBeTrue();
            expect($output.contains(item.email)).toBeTrue();
        });
    });

});
