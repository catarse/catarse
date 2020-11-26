import mq from 'mithril-query'
import { Balance, UserId } from '../../../../../../src/root/users/edit/#balance/controllers/use-cases/entities'
import { createBalance } from '../create-balance'
import { UserDetails } from '../../../../../../src/entities'
import { UserBalanceAmount } from '../../../../../../src/root/users/edit/#balance/user-balance-amount/user-balance-amount'

describe('UserBalanceAmount', () => {

    describe('view', () => {
        it('should show withdraw modal when click withdraw request button', () => {
            // 1. Arrange
            const balance : Balance = {
                user_id: 1,
                amount: 1000,
                last_transfer_amount: 1000,
                last_transfer_created_at: new Date().toISOString(),
                in_period_yet: false,
                has_cancelation_request: false,
            }
            const user = { id : 1 } as UserDetails
            const useBalanceAmountOf = (user : UserId) => ({ isLoading: false, balance })
            const component = mq(<UserBalanceAmount user={user} useBalanceAmountOf={useBalanceAmountOf} />)
    
            // 2. act?
            component.click('.btn-withdraw-request-process-start', new Event('click'))
    
            // 3. assert
            component.should.have('.modal-backdrop')
        })

        it('should have withdraw button enabled when balance is > 0 and have not withdraw yet', () => {
            // 1. Arrange
            const balance : Balance = {
                user_id: 1,
                amount: 1000,
                last_transfer_amount: 1000,
                last_transfer_created_at: new Date().toISOString(),
                in_period_yet: false,
                has_cancelation_request: false,
            }
            const user = { id : 1 } as UserDetails
            const useBalanceAmountOf = (user : UserId) => ({ isLoading: false, balance })
            const component = mq(<UserBalanceAmount user={user} useBalanceAmountOf={useBalanceAmountOf} />)
    
            // 2. act?
    
            // 3. assert
            component.should.not.have('.btn-inactive.btn-withdraw-request-process-start')
        })

        it('should not have withdraw button enabled when have made withdraw within the period', () => {
            // 1. Arrange
            const balance : Balance = {
                user_id: 1,
                amount: 1000,
                last_transfer_amount: 1000,
                last_transfer_created_at: new Date().toISOString(),
                in_period_yet: true,
                has_cancelation_request: false,
            }
            const user = { id : 1 } as UserDetails
            const useBalanceAmountOf = (user : UserId) => ({ isLoading: false, balance })
            const component = mq(<UserBalanceAmount user={user} useBalanceAmountOf={useBalanceAmountOf} />)
    
            // 2. act?
    
            // 3. assert
            component.should.have('.btn-inactive.btn-withdraw-request-process-start')
        })
    })
})