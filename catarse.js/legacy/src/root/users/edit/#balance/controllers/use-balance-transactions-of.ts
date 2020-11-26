import { ViewModel } from '../../../../../entities'
import { useEffect, useState } from 'mithril-hooks'
import { LoadUserBalanceTransactions } from './use-cases'
import { UserId, BalanceTransaction } from './use-cases/entities'
import { UserBalanceTransactionsSubscription } from './user-withdraw-history-subscription'

export function useBalanceTransactionsOf(user : UserId, loadUserBalanceTransactions : LoadUserBalanceTransactions, newTransactions : UserBalanceTransactionsSubscription) {
    
    const [ transactionsHistoryViewModel, setTransactionsHistoryViewModel ] = useState<ViewModel<BalanceTransaction>>(null)

    useEffect(() => {
        setTransactionsHistoryViewModel(loadUserBalanceTransactions(user))

        newTransactions.subscribe(() => {
            setTransactionsHistoryViewModel(loadUserBalanceTransactions(user))
        })
    }, [])
    
    return {
        transactions: transactionsHistoryViewModel?.collection() || [],
        isLoading: transactionsHistoryViewModel?.isLoading(),
        isLastPage: transactionsHistoryViewModel?.isLastPage(),
        loadNextPage: () => transactionsHistoryViewModel?.nextPage()
    }
}