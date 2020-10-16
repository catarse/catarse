import mq from 'mithril-query';
import m from 'mithril';
import copyTextInput from '../../src/c/copy-text-input';

describe('copyTextInput', () => {
    let $output, testValue = 'Some value';

    describe('view', () => {
        beforeAll(() => {
            $output = mq(m(copyTextInput, {value: testValue}));
        });

        it('should render a text field with the set value', () => {
            expect($output.find('.copy-textarea').length).toEqual(1);
            expect($output.contains(testValue)).toBeTrue();
        });

        it('should copy the content of the text area on click', () => {
            // There isn't a way to actually render the component on the DOM
            // so we can't actually copy and test what was copied.
            pending();
        });
    });
});
