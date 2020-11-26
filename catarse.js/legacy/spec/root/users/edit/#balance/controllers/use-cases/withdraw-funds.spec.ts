import { withdrawFunds } from '../../../../../../../src/root/users/edit/#balance/controllers/use-cases'
import { apiCatarseAddress } from '../../../../../../lib/configs/apis-address'
import { UserId } from '../../../../../../../src/root/users/edit/#balance/controllers/use-cases/entities'

describe('WithdrawFunds', () => {
    it('should create withdraw request', async () => {
        // 1. Arrange
        const user : UserId = {
            id: 1
        }

        const loadUrl = `${apiCatarseAddress}/balance_transfers`

        jasmine.Ajax.stubRequest(loadUrl).andReturn({
            responseText: JSON.stringify({ success: 'OK' })
        })

        // 2. Act
        await withdrawFunds(user)

        // 3. Assert
        expect(jasmine.Ajax.requests.mostRecent().status).toEqual(200)
        expect(jasmine.Ajax.requests.mostRecent().response).toEqual(JSON.stringify({ success : 'OK' }))
    })
})