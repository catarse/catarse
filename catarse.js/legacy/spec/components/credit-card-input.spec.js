import mq from 'mithril-query';
import m from 'mithril';
import prop from 'mithril/stream';
import creditCardInput from '../../src/c/credit-card-input';

describe('CreditCardInput', () => {
    let $output,
        test = {
            class: 'test_class',
            value: prop('test_value'),
            name: 'test_name',
            focusFn: jasmine.createSpy('onfocus')
        };

    describe('view', () => {
        beforeAll(() => {
            $output = mq(
                m(creditCardInput, {
                    onfocus: test.focusFn,
                    class: test.class,
                    value: test.value,
                    name: test.name
                })
            );
        });

        it('should build a credit card input', () => {
            expect($output.has('input[type="tel"]')).toBeTrue();
        });
        it('should set the given input name', () => {
            expect($output.has(`input[name="${test.name}"]`)).toBeTrue();
        });
        it('should call the given focus function on focus', () => {
            $output.focus('input');
            expect(test.focusFn).toHaveBeenCalled();
        });
    });
});
