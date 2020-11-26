import { apiCatarseAddress } from '../../../../../../lib/configs/apis-address'
import { UserId, UserBalanceTransfer } from '../../../../../../../src/root/users/edit/#balance/controllers/use-cases/entities'
import { loadUserWithdrawHistory } from '../../../../../../../src/root/users/edit/#balance/controllers/use-cases'
import { createUserBalanceTransfers } from '../../create-user-balance-transfers'

describe('LoadUserWithdrawRequestHistory', () => {

    it('should load user balance withdraw request history', async () => {
        // 1. Arrange
        const user : UserId = {
            id: 1
        }
        
        const userBalanceWithdrawHistory : UserBalanceTransfer[] = createUserBalanceTransfers()

        const loadUrl = `${apiCatarseAddress}/user_balance_transfers?order=requested_in.desc&user_id=eq.${user.id}`
        jasmine.Ajax.stubRequest(loadUrl).andReturn({
            responseHeaders: {
                'Content-Range' : `0-${userBalanceWithdrawHistory.length}/*`
            },
            responseText: JSON.stringify(userBalanceWithdrawHistory)
        })

        // 2. Act
        const userBalanceWithdrawHistoryLoaded = loadUserWithdrawHistory(user)

        // 3. Assert
        userBalanceWithdrawHistoryLoaded.collection().map(userBalancetrasactions => {
            expect(userBalanceWithdrawHistoryLoaded.collection()).toEqual(jasmine.objectContaining(userBalancetrasactions))
        })
    })
})