import mq from 'mithril-query';
import teamTotal from '../../src/c/team-total';

describe('TeamTotal', () => {
    let $output;

    describe('view', () => {
        beforeAll(() => {
            $output = mq(teamTotal);
        });

        it('should render fetched team total info', () => {
            expect($output.find('#team-total-static').length).toEqual(1);
        });
    });
});
