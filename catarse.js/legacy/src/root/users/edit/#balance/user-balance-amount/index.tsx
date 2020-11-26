import { UserBalanceAmount, UserBalanceAmountServices, UserBalanceAmountProps } from './user-balance-amount'
import { UserId } from '../controllers/use-cases/entities'
import { useBalanceAmountOf } from '../controllers/use-balance-amount-of'
import { loadUserBalance } from '../controllers/use-cases'
import { CreateHOC } from '../../../../../shared/components/create-hoc'
import { userBalanceTransactionsSubscription } from '../controllers/store/user-balance-withdraw-history-subscription-subjects'

export const UserBalanceAmountWithServices = CreateHOC<UserBalanceAmountServices, UserBalanceAmountProps>({
    WrappedComponent: UserBalanceAmount,
    injectable: {
        useBalanceAmountOf(user : UserId) {
            return useBalanceAmountOf(user, loadUserBalance, userBalanceTransactionsSubscription)
        }
    }
})