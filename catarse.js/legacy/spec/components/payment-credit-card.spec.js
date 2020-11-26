import mq from 'mithril-query';
// import render from 'mithril-node-render';
import m from 'mithril';
import paymentCreditCard from '../../src/c/payment-credit-card';
import paymentVM from '../../src/vms/payment-vm';

describe('paymentCreditCard', () => {
    let $output, vm;
    describe('view', () => {
        beforeAll(() => {
            window.pagarme = {};
            vm = paymentVM();
            vm.fields.ownerDocument('568.905.638-32');
            spyOn(vm, 'sendPayment').and.returnValue(new Promise(() => {}));
            let test = {
                vm: vm,
                contribution_id: 1,
                project_id: 1,
                user_id: 1,
                isSubscriptionEdit: () => false                
            };
            $output = mq(paymentCreditCard, test);
        });

        it('should build a credit card payment form', () => {
            // expect($output.has('form[name="email-form"]')).toBeTrue();
        });

        it('should display saved credit cards', () => {
            // expect($output.should.have.at.least(1, '.back-payment-credit-card-radio-field')).toBeTrue();
        });

        describe('when values are not valid', () => {
            beforeAll(() => {

                // $output.click('#credit-card-record-1');
                // $output.setValue('select[name="expiration-date_month"]', '1');
                // $output.setValue('select[name="expiration-date_year"]', '2016');
                // $output.setValue('input[name="credit-card-number"]', '1234567812345678');
                // $output.setValue('input[name="credit-card-name"]', '123');
                // $output.setValue('input[name="credit-card-cvv"]', 'abc');
                // $output.trigger('form', 'onsubmit');
            });

            it('should return an error if expiry date is not valid', () => {
                // expect($output.find('select.error').length > 0).toBeTruthy();
            });
            it('should return an error if credit card number is not valid', () => {
                // expect($output.find('input[name="credit-card-number"].error').length > 0).toBeTruthy();
            });
            it('should return an error if credit card name is not valid', () => {
                // expect($output.find('input[name="credit-card-name"].error').length > 0).toBeTrue();
            });
            it('should return an error if cvv is not valid', () => {
                // expect($output.find('input[name="credit-card-cvv"].error').length > 0).toBeTrue();
            })
        });
        describe('when values are valid', () => {
            beforeAll(() => {

                // $output.vnode.state.showForm(false);
                // $output.setValue('select[name="expiration-date_month"]', '10');
                // $output.setValue('select[name="expiration-date_year"]', '2026');
                // vm.creditCardFields.number('4012 8888 8888 1881');
                // $output.setValue('input[name="credit-card-cvv"]', '123');
                // $output.setValue('input[name="credit-card-name"]', 'Tester');
            });

            it('should send a payment request', () => {

                // $output.trigger('form', 'onsubmit');
                // expect(vm.sendPayment).toHaveBeenCalled();
            });
        })
    });
});
