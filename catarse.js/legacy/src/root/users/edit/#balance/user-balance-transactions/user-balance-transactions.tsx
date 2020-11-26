import m from 'mithril'
import h from '../../../../../h'
import { UserBalanceTransactionRow } from './user-balance-transaction-row'
import { withHooks } from 'mithril-hooks'
import { ViewModel, UserDetails } from '../../../../../entities'
import { Loader } from '../../../../../shared/components/loader'
import { useBalanceTransactionsOf } from '../controllers/use-balance-transactions-of'
import { I18nText } from '../../../../../shared/components/i18n-text'
import { UserId, BalanceTransaction } from '../controllers/use-cases/entities'

export type UserBalanceTransactionsProps = {
    user: UserId
}

export type UserBalanceTransactionsServices = {
    useBalanceTransactionsOf(user : UserId): {
        transactions: BalanceTransaction[]
        isLoading: boolean
        isLastPage: boolean
        loadNextPage(): void
    }
}

type UserBalanceTransactionsPropsAndServices = UserBalanceTransactionsProps & UserBalanceTransactionsServices

export const UserBalanceTransactions = withHooks<UserBalanceTransactionsPropsAndServices>(_UserBalanceTransactions)

function _UserBalanceTransactions({user, useBalanceTransactionsOf} : UserBalanceTransactionsPropsAndServices) {

    const {
        transactions,
        isLoading,
        isLastPage,
        loadNextPage,
    } = useBalanceTransactionsOf(user)

    return (
        <div class='w-section section card-terciary before-footer balance-transactions-area'>
            <div class='w-container'>
                <div class='u-marginbottom-20'>
                    <div class='fontsize-base fontweight-semibold'>
                        <I18nText scope='users.balance.activities_group' />
                    </div>
                </div>
                {
                    transactions.map((transaction, index) => (
                        <UserBalanceTransactionRow transaction={transaction} index={index} />
                    ))
                }
            </div>
            <div class='container'>
                <div class='w-row u-margintop-40'>
                    <div class='w-col w-col-2 w-col-push-5'>
                        {
                            isLoading ?
                                <Loader />
                                :
                                !isLastPage &&
                                <button onclick={loadNextPage} id='load-more' class='btn btn-medium btn-terciary'>
                                    Carregar mais
                                </button>
                        }
                    </div>
                </div>
            </div>
        </div>
    )
}