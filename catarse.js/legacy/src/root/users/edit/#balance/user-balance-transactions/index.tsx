import { CreateHOC } from '../../../../../shared/components/create-hoc'
import { UserBalanceTransactionsProps, UserBalanceTransactionsServices, UserBalanceTransactions } from './user-balance-transactions'
import { useBalanceTransactionsOf } from '../controllers/use-balance-transactions-of'
import { loadUserBalanceTransactions } from '../controllers/use-cases'
import { userBalanceTransactionsSubscription } from '../controllers/store/user-balance-withdraw-history-subscription-subjects'

export const UserBalanceTransactionsWithServices = CreateHOC<UserBalanceTransactionsServices, UserBalanceTransactionsProps>({
    WrappedComponent: UserBalanceTransactions,
    injectable: {
        useBalanceTransactionsOf(user) {
            return useBalanceTransactionsOf(user, loadUserBalanceTransactions, userBalanceTransactionsSubscription)
        }
    }
})