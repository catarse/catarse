import { ViewModel } from '../../../../../entities'
import { LoadUserWithdrawRequestHistory } from './use-cases'
import { useEffect, useState } from 'mithril-hooks'
import { UserId, UserBalanceTransfer } from './use-cases/entities'
import { UserBalanceTransactionsSubscription } from './user-withdraw-history-subscription'

export function useBalanceWithdrawHistoryOf(user : UserId, loadUserWithdrawHistory : LoadUserWithdrawRequestHistory, newTransactions : UserBalanceTransactionsSubscription) {

    const [ withdrawRequestHistoryPagination, setWithdrawRequestHistoryPagination ] = useState<ViewModel<UserBalanceTransfer>>(null)

    useEffect(() => {
        setWithdrawRequestHistoryPagination(loadUserWithdrawHistory(user))

        newTransactions.subscribe(() => {
            setWithdrawRequestHistoryPagination(loadUserWithdrawHistory(user))
        })
    }, [])
    
    return {
        withdrawRequestHistory: withdrawRequestHistoryPagination?.collection() || [],
        isLoading: withdrawRequestHistoryPagination?.isLoading(),
        isLastPage: withdrawRequestHistoryPagination?.isLastPage(),
        loadNextPage: () => withdrawRequestHistoryPagination?.nextPage()
    }
}