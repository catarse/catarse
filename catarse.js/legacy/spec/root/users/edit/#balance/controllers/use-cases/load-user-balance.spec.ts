import { apiCatarseAddress } from '../../../../../../lib/configs/apis-address'
import { UserId } from '../../../../../../../src/root/users/edit/#balance/controllers/use-cases/entities'
import { createBalance } from '../../create-balance'
import { loadUserBalance } from '../../../../../../../src/root/users/edit/#balance/controllers/use-cases'

describe('LoadUserBalance', () => {

    it('should load user balance', async () => {
        // 1. Arrange
        const user : UserId = {
            id: 1
        }
        const balance = createBalance()
        const loadUrl = `${apiCatarseAddress}/balances?user_id=eq.${user.id}`
        jasmine.Ajax.stubRequest(loadUrl).andReturn({
            responseText: JSON.stringify([balance])
        })

        // 2. Act
        const balanceLoaded = await loadUserBalance(user)

        // 3. Assert
        expect(balanceLoaded).toEqual(jasmine.objectContaining(balance))
    })
})