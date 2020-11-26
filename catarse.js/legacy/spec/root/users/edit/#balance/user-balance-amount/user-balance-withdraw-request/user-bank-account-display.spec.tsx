import mq from 'mithril-query'
import { createBankAccount } from '../../create-bank-account'
import { createBalance } from '../../create-balance'
import { UserBankAccountDisplay } from '../../../../../../../src/root/users/edit/#balance/user-balance-amount/user-balance-withdraw-request/user-bank-account-display'

describe('UserBankAccountDisplay', () => {
    it('should display bank account', () => {
        // 1. arrange
        const bankAccount = createBankAccount()
        const balance = createBalance()
        const component = mq(<UserBankAccountDisplay bankAccount={bankAccount} balance={balance} />)

        // 2. act ?

        // 3. assert
        component.should.contain(bankAccount.bank_name)
        component.should.contain(`${bankAccount.account}-${bankAccount.account_digit}`)
        component.should.contain(`${bankAccount.agency}-${bankAccount.agency_digit}`)
    })
})