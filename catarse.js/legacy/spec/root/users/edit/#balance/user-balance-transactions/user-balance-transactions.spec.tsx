import mq from 'mithril-query'
import { BalanceTransaction, UserId } from '../../../../../../src/root/users/edit/#balance/controllers/use-cases/entities'
import { UserBalanceTransactionsProps, UserBalanceTransactions } from '../../../../../../src/root/users/edit/#balance/user-balance-transactions/user-balance-transactions'

describe('UserBalanceTransactions', () => {
    describe('view', () => {

        it('should diplay first page transactions', () => {
            // 1. Arrange
            const transactions : BalanceTransaction[] = [
                {
                    credit: 1000,
                    debit: 0,
                    source: [],
                    total_amount: 1000,
                    user_id: 1,
                    created_at: new Date().toISOString()
                }
            ]

            const hookResponse = {
                transactions,
                isLoading: false,
                isLastPage: false,
                loadNextPage() { }
            }

            const props : UserBalanceTransactionsProps = {
                user: {
                    id: 1
                },
                useBalanceTransactionsOf: (user : UserId) => hookResponse,
            }

            spyOn(hookResponse.transactions, 'map')
            
            const component = mq(<UserBalanceTransactions user={props.user} useBalanceTransactionsOf={props.useBalanceTransactionsOf} />)

            // 2. Act?

            // 3. Assert
            expect(hookResponse.transactions.map).toHaveBeenCalled()
        })

        it('should load next page of transactions', () => {            
            // 1. Arrange
            const transactions : BalanceTransaction[] = [
                {
                    credit: 1000,
                    debit: 0,
                    source: [],
                    total_amount: 1000,
                    user_id: 1,
                    created_at: new Date().toISOString()
                }
            ]

            const hookResponse = {
                transactions,
                isLoading: false,
                isLastPage: false,
                loadNextPage() { }
            }

            const props : UserBalanceTransactionsProps = {
                user: {
                    id: 1
                },
                useBalanceTransactionsOf: (user : UserId) => hookResponse,
            }

            spyOn(hookResponse, 'loadNextPage')
            
            const component = mq(<UserBalanceTransactions user={props.user} useBalanceTransactionsOf={props.useBalanceTransactionsOf} />)

            // 2. Act
            component.click('#load-more', new Event('click'))

            // 3. Assert
            expect(hookResponse.loadNextPage).toHaveBeenCalled()
        })
    })
})