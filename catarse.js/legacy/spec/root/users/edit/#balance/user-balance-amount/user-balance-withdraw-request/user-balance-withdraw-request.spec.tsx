import mq from 'mithril-query'
import { UserBalanceWithdrawRequest, UserBalanceRequestProps, UserBalanceRequestServices } from '../../../../../../../src/root/users/edit/#balance/user-balance-amount/user-balance-withdraw-request/user-balance-withdraw-request'
import { BankAccount } from '../../../../../../../src/root/users/edit/#balance/controllers/use-cases/entities'
import { WithdrawRequestStage } from '../../../../../../../src/root/users/edit/#balance/controllers/use-cases/entities/withdraw-request-stage'
import { UserDetails } from '../../../../../../../src/entities'
import { waitFor } from '../../../../../../lib/wait-for'

describe('UserBalanceWithdrawRequest', () => {
    describe('view', () => {

        const bankAccount : BankAccount = {
            bank_account_id: 1,
            account: '123923',
            account_digit: '0',
            agency: '1234',
            agency_digit: '1',
            bank_id: 1000,
            account_type: 'conta_corrent',
            bank_code: '104',
            bank_name: 'CEF',
            created_at: null,
            owner_document: '12345678910',
            owner_name: 'Bank Account User Name',
            updated_at: null,
            user_id: 1,
        }
        
        const serviceData = {
            goBackToForm() {

            },
            isLoading: false,
            setBankAccount(newBankAccount) {

            },
            setManualBankCode(newManualCode) {

            },
            stage: WithdrawRequestStage.FILL_FORM,
            async withdraw() {

            },
            async bankAccountUpdate() {

            },
            bankAccount,
            onChange(bankAccount : BankAccount) {
                
            },
            manualBankCode: '',
            onChangeManualBankCode(bankCode : string) {

            },
            banks: [],
            getErrors(field : string) {
                return []
            }                
        }

        const props : UserBalanceRequestProps & UserBalanceRequestServices = {
            user: {
                account_type: 'pf',
                email: 'email@email.com',
                id: 1,
                name: 'USER NAME',
                owner_document: '123.456.789-10',
                permalink: '',
                public_name: 'PUBLIC USER NAME'
            } as UserDetails,
            balance: {
                amount: 1000,
                has_cancelation_request: false,
                in_period_yet: false,
                last_transfer_amount: 0,
                last_transfer_created_at: null,
                user_id: 1
            },
            useWithdrawRequestFor(user) {
                return serviceData
            }
        }

        it('should render bank account fill form', () => {
            // 1. arrange
            const component = mq(<UserBalanceWithdrawRequest {...props} />)

            // 2. act?

            // 3. assert
            component.should.have('#withdraw-request-form')
        })

        it('should render bank account fill form and when request update bank account render confirmation', async () => {
            // 1. arrange
            const localServiceData = { ...serviceData }
            const localProps : UserBalanceRequestProps & UserBalanceRequestServices = { ...props, useWithdrawRequestFor: (u) => localServiceData }
            spyOn(localServiceData, 'bankAccountUpdate').and.callFake(async () => {
                localServiceData.stage = WithdrawRequestStage.CONFIRM_BANK_ACCOUNT
            })
            const component = mq(<UserBalanceWithdrawRequest user={localProps.user} balance={localProps.balance} useWithdrawRequestFor={localProps.useWithdrawRequestFor} />)

            // 2. act?
            component.click('.btn-request-fund', new Event('click'))

            // 3. assert
            expect(localServiceData.bankAccountUpdate).toHaveBeenCalled()
            component.should.have('#bank-account-confirmation')
        })

        it('should render bank account confirmation and click withdraw to show request operation done', async () => {
            // 1. arrange
            const localServiceData = { ...serviceData, stage: WithdrawRequestStage.CONFIRM_BANK_ACCOUNT }
            const localProps : UserBalanceRequestProps & UserBalanceRequestServices = { ...props, useWithdrawRequestFor: (u) => localServiceData }
            spyOn(localServiceData, 'withdraw').and.callFake(async () => {
                localServiceData.stage = WithdrawRequestStage.SUCCESS
            })
            const component = mq(<UserBalanceWithdrawRequest user={localProps.user} balance={localProps.balance} useWithdrawRequestFor={localProps.useWithdrawRequestFor} />)

            // 2. act?
            component.click('#bank-account-confirmation .btn-request-fund', new Event('click'))

            // 3. assert
            expect(localServiceData.withdraw).toHaveBeenCalled()
            component.should.have('#withdraw-request-done')
        })
    })
})
