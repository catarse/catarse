import { CreateHOC } from '../../../../../shared/components/create-hoc'
import { UserBalanceWithdrawHistory, UserBalanceWithdrawHistoryProps, UserBalanceWithdrawHistoryServices } from './user-balance-withdraw-history'
import { useBalanceWithdrawHistoryOf } from '../controllers/use-balance-withdraw-history-of'
import { loadUserWithdrawHistory } from '../controllers/use-cases'
import { userBalanceTransactionsSubscription } from '../controllers/store/user-balance-withdraw-history-subscription-subjects'

export const UserBalanceWithdrawHistoryWithServices = CreateHOC<UserBalanceWithdrawHistoryServices, UserBalanceWithdrawHistoryProps>({
    WrappedComponent: UserBalanceWithdrawHistory,
    injectable: {
        useBalanceWithdrawHistoryOf(user) {
            return useBalanceWithdrawHistoryOf(user, loadUserWithdrawHistory, userBalanceTransactionsSubscription)
        }
    }
})