import { CreateHOC } from '../../../../../../shared/components/create-hoc'
import { useWithdrawRequestFor } from '../../controllers/use-withdraw-request-for'
import { UserBalanceRequestProps, UserBalanceWithdrawRequest, UserBalanceRequestServices } from './user-balance-withdraw-request'
import { loadBanks, loadUserBankAccount, updateUserBankAccount, withdrawFunds } from '../../controllers/use-cases'
import { userBalanceTransactionsSubject } from '../../controllers/store/user-balance-withdraw-history-subscription-subjects'

export const UserBalanceWithdrawRequestWithServices = CreateHOC<UserBalanceRequestServices, UserBalanceRequestProps>({
    WrappedComponent: UserBalanceWithdrawRequest,
    injectable: {
        useWithdrawRequestFor(user) {
            return useWithdrawRequestFor(user, { loadBanks, loadUserBankAccount, updateUserBankAccount, withdrawFunds, updateSubject: userBalanceTransactionsSubject })
        }
    }
})