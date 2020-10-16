import m from 'mithril';
import prop from 'mithril/stream';
import mq from 'mithril-query';
import userBalanceRequestModelContent from '../../src/c/user-balance-request-modal-content';
import { catarse } from '../../src/api';
import models from '../../src/models';

xdescribe('UserBalanceRequestModalContent', () => {
    describe('view', function () {
        const user_id = 1000;
        const userIdVM = catarse.filtersVM({ user_id: 'eq' });

        let attrs = null;
        let userBankAccount = null;
        let component = null;

        beforeAll(() => {
            // User Bank Account
            // catarse api /bank_accounts?user_id=eq.1000
            jasmine.Ajax.stubRequest(new RegExp('(' + apiPrefix + `\/bank_accounts?user_id=eq.${user_id})` + '(.*)')).andReturn({
                responseText: JSON.stringify([
                    UserBalanceRequestModalContentUserBankAccountMock()
                ])
            });

            attrs = UserBalanceRequestModalContentMock();
            userBankAccount = UserBalanceRequestModalContentUserBankAccountMock();
            userIdVM.user_id(user_id);
            attrs.bankCode = prop('');
            attrs.bankInput = prop('');
            attrs.balanceManager = (() => {
                const collection = prop([{ amount: 0, user_id }]);
                const load = () => {
                    return models.balance
                        .getRowWithToken(userIdVM.parameters())
                        .then(collection)
                        .then(_ => m.redraw());
                };

                return {
                    collection,
                    load
                };
            })();
            attrs.bankAccountManager = (() => {
                const collection = prop([]);
                const loader = (() => catarse.loaderWithToken(models.bankAccount.getRowOptions(userIdVM.parameters())))();
                const load = () => {
                    return loader
                        .load()
                        .then(collection)
                        .then(() => m.redraw());
                };

                return {
                    collection,
                    load,
                    loader
                };
            })();
            component = mq(m(userBalanceRequestModelContent, attrs));
        });

        it('should load user bank account', (done) => {
            const testInterval = setInterval(() => {
                try {
                    component.should.have(`select.select.required.w-input.text-field.bank-select.positive > option[value='${userBankAccount.bank_id}']`);
                    clearInterval(testInterval);
                    done();
                } catch (e) {

                }
            }, 50);
        });
    });
});
