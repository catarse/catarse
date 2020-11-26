import { UserId, Balance } from './use-cases/entities'
import { useState, useEffect } from 'mithril-hooks'
import { LoadUserBalance } from './use-cases'
import { UserBalanceTransactionsSubscription } from './user-withdraw-history-subscription'

export function useBalanceAmountOf(user : UserId, loadUserBalance : LoadUserBalance, newTransactions : UserBalanceTransactionsSubscription) {

    const [ isLoading, setIsLoading ] = useState(true)
    const [ balance, setBalance ] = useState<Balance>(null)
    
    useEffect(() => {
        const loadAll = async () => {
            try {
                setIsLoading(true)
                setBalance(await loadUserBalance(user))
            } catch(error) {
                console.log('Error loading user balance data:', error.stack)
            } finally {
                setIsLoading(false)
            }
        }

        loadAll()

        newTransactions.subscribe(async () => {
            setBalance(await loadUserBalance(user))
        })

    }, [user.id])

    return {
        isLoading,
        balance,
    }
}