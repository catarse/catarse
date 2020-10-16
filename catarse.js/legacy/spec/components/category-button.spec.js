import mq from 'mithril-query';
import m from 'mithril';
import categoryButton from '../../src/c/category-button';

describe('CategoryButton', () => {
    let $output,
        c = window.c;

    describe('view', () => {
        beforeAll(() => {
            $output = mq(m(categoryButton, {
                category: {
                    id: 1,
                    name: 'cat',
                    online_projects: 1
                }
            }));
        });

        it('should build a link with .btn-category', function() {
            expect($output.has('a.btn-category')).toBeTrue();
        });
    });
});
