import mq from 'mithril-query'
import { BankAccount, Balance } from '../../../../../../../src/root/users/edit/#balance/controllers/use-cases/entities'
import { createBankAccount } from '../../create-bank-account'
import { createBalance } from '../../create-balance'
import { BankAccountConfirmation } from '../../../../../../../src/root/users/edit/#balance/user-balance-amount/user-balance-withdraw-request/bank-account-confirmation'

describe('BankAccountConfirmation', () => {

    const mockBankAccount : BankAccount = createBankAccount()
    const mockBalance : Balance = createBalance()

    it('should confirm bank account', () => {
        // 1. arrange
        const props = {
            bankAccount: mockBankAccount,
            balance: mockBalance,
            goBackToForm: () => {},
            withdraw: () => {},
        }
        spyOn(props, 'withdraw')
        const component = mq(<BankAccountConfirmation {...props}/>)

        // 2. act
        component.click('.btn-request-fund', new Event('click'))

        // 3. assert
        expect(props.withdraw).toHaveBeenCalled()
    })

    it('should go back to fill form', () => {
        // 1. arrange
        const props = {
            bankAccount: mockBankAccount,
            balance: mockBalance,
            goBackToForm: () => {},
            withdraw: () => {},
        }
        spyOn(props, 'goBackToForm')
        const component = mq(<BankAccountConfirmation {...props}/>)

        // 2. act
        component.click('.btn-go-back-to-form', new Event('click'))

        // 3. assert
        expect(props.goBackToForm).toHaveBeenCalled()
    })
})