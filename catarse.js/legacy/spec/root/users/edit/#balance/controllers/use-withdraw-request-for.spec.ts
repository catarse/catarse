import { useWithdrawRequestFor, UseWithdrawRequestForDependencies, UseWithdrawRequestForReturn } from '../../../../../../src/root/users/edit/#balance/controllers/use-withdraw-request-for'
import { BankAccount, UserBalanceTransfer } from '../../../../../../src/root/users/edit/#balance/controllers/use-cases/entities'
import { setupCustomHook } from '../../../../../lib/setup-custom-hook'
import { UserDetails } from '../../../../../../src/entities'
import type {} from 'jasmine'

describe('useWithdrawRequestFor', () => {
    it('should retrieve empty bank account on first load', () => {
        const user = {
            id: 11,
            owner_document: '0000000000',
            name: '__________'
        } as UserDetails

        const deps : UseWithdrawRequestForDependencies = {
            loadBanks: async () => [],
            loadUserBankAccount: async () => ({} as BankAccount),
            updateSubject: {
                next: () => {}
            },
            updateUserBankAccount: async () => {},
            withdrawFunds: async () => ({} as UserBalanceTransfer),
        }

        const { bankAccount } = setupCustomHook(useWithdrawRequestFor, user, deps) as UseWithdrawRequestForReturn

        expect(bankAccount).toEqual(jasmine.objectContaining({
            account: '',
            account_digit: '',
            account_type: 'conta_corrente',
            agency: '',
            agency_digit: '',
            bank_code: '',
            bank_account_id: null,
            bank_name: '',
            created_at: null,
            owner_document: user.owner_document,
            owner_name: user.name,
            updated_at: null,
            user_id: null,
        } as BankAccount))
    })
})