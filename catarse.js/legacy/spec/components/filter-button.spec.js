import mq from 'mithril-query';
import m from 'mithril';
import filterButton from '../../src/c/filter-button';

describe('FilterButton', () => {
    let $output;

    describe('view', () => {
        beforeAll(() => {
            $output = mq(m(filterButton, {
                title: 'Test',
                href: 'test'
            }));
        });

        it('should build a link with .filters', () => {
            expect($output.has('a.filters')).toBeTrue();
        });
    });
});
