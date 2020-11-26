import { apiCatarseAddress } from '../../../../../../lib/configs/apis-address'
import { UserId, BalanceTransaction } from '../../../../../../../src/root/users/edit/#balance/controllers/use-cases/entities'
import { loadUserBalanceTransactions } from '../../../../../../../src/root/users/edit/#balance/controllers/use-cases'

describe('LoadUserBalanceTransactions', () => {

    it('should load user balance transactions', async () => {
        // 1. Arrange
        const user : UserId = {
            id: 1
        }
        
        const balanceTransactions : BalanceTransaction = {
            user_id: 1,
            credit: 0,
            debit: -3000,
            total_amount: -3000,
            created_at: "2020-06-28",
            source:[]
        }

        const loadUrl = `${apiCatarseAddress}/balance_transactions?order=created_at.desc&user_id=eq.${user.id}`
        jasmine.Ajax.stubRequest(loadUrl).andReturn({
            responseHeaders: {
                'Content-Range' : '0-1/*'
            },
            responseText: JSON.stringify([balanceTransactions])
        })

        // 2. Act
        const balanceTransactionsLoaded = loadUserBalanceTransactions(user)

        // 3. Assert
        balanceTransactionsLoaded.collection().map(userBalancetrasactions => {
            expect(balanceTransactionsLoaded.collection()).toEqual(jasmine.objectContaining([balanceTransactions]))
        })
    })
})