import mq from 'mithril-query';
import m from 'mithril';
import prop from 'mithril/stream';
import adminTransaction from '../../src/c/admin-transaction';

describe('AdminTransaction', () => {
    let contribution,
        view, $output;

    beforeAll(() => {
        contribution = prop(ContributionDetailMockery(1, {
            gateway_data: null
        }));

        $output = mq(adminTransaction, {
            contribution: contribution()[0]
        });
    });

    describe('view', () => {
        it('should render details about contribution', () => {
            expect($output.contains('Valor: R$50,00')).toBeTrue();
            expect($output.contains('Meio: MoIP')).toBeTrue();
        });
    });
});
