/* global 
    describe, 
    beforeAll, 
    it,
*/
import m from 'mithril';
import prop from 'mithril/stream';
import mq from 'mithril-query';
import userSettingsVM from '../../src/vms/user-settings-vm';
import userBankForm from '../../src/c/user-bank-form';

describe('UserBankForm', () => {
    describe('view', () => {
        let component = null;
        const userBankAccount = {
            bank_account_id: 1,
            account: '123923',
            account_digit: '0',
            agency: '1234',
            agency_digit: '1',
            bank_id: 1000,
            account_type: 'conta_corrent',
        };
        const attrs = {
            user: {
                id: 1000
            },
            parsedErrors: userSettingsVM.mapRailsErrors([]),
            fields: {
                agency: prop(userBankAccount.agency),
                bank_id: prop(userBankAccount.bank_id),
                agency_digit: prop(userBankAccount.agency_digit),
                account: prop(userBankAccount.account),
                account_digit: prop(userBankAccount.account_digit),
                bank_account_id: prop(userBankAccount.bank_account_id),
                bank_account_type: prop(userBankAccount.account_type),
            },
            bankInput: prop(''),
            bankCode: prop('-1'),
            userBankAccount: prop(userBankAccount)
        };

        beforeAll(() => {
            component = mq(m(userBankForm, attrs));
        });
        
        it('should have user bank account', () => {
            component.should.have(`select.select.required.w-input.text-field.bank-select.positive[name="user[bank_account_attributes][bank_id]"] option[value='${userBankAccount.bank_id}']`);
            component.should.have(`input.string.required.w-input.text-field.positive[value=${userBankAccount.agency}]`);
        });
    });
});
