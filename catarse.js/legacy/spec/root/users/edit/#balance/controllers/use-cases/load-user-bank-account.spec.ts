import { createBankAccount } from '../../create-bank-account'
import { UserId } from '../../../../../../../src/root/users/edit/#balance/controllers/use-cases/entities'
import { apiCatarseAddress } from '../../../../../../lib/configs/apis-address'
import { loadUserBankAccount } from '../../../../../../../src/root/users/edit/#balance/controllers/use-cases'

describe('LoadUserBankAccount', () => {

    it('should load user bank account', async () => {
        // 1. Arrange
        const user : UserId = {
            id: 1
        }
        
        const bankAccount = createBankAccount()

        const loadUrl = `${apiCatarseAddress}/bank_accounts?user_id=eq.${user.id}`
        jasmine.Ajax.stubRequest(loadUrl).andReturn({
            responseText: JSON.stringify([bankAccount])
        })

        // 2. Act
        const loadedBankAccount = await loadUserBankAccount(user)

        // 3. Assert
        expect(loadedBankAccount).toEqual(jasmine.objectContaining(bankAccount))
    })
})