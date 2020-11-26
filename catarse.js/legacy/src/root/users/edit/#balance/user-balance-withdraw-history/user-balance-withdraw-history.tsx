import { withHooks } from 'mithril-hooks'
import { UserBalanceWithdrawHistoryItemRequest } from './user-balance-withdraw-history-item-request';
import { UserId, UserBalanceTransfer } from '../controllers/use-cases/entities'
import { Loader } from '../../../../../shared/components/loader'
import { I18nText } from '../../../../../shared/components/i18n-text'

export type UserBalanceWithdrawHistoryProps = {
    user: UserId
}

export type UserBalanceWithdrawHistoryServices = {
    useBalanceWithdrawHistoryOf(user: UserId): {
        withdrawRequestHistory: UserBalanceTransfer[];
        isLoading: boolean;
        isLastPage: boolean;
        loadNextPage: () => Promise<UserBalanceTransfer[]>;
    }
}

type UserBalanceWithdrawHistoryPropsAndServices = UserBalanceWithdrawHistoryProps & UserBalanceWithdrawHistoryServices

export const UserBalanceWithdrawHistory = withHooks<UserBalanceWithdrawHistoryPropsAndServices>(_UserBalanceWithdrawHistory)

function _UserBalanceWithdrawHistory({user, useBalanceWithdrawHistoryOf} : UserBalanceWithdrawHistoryPropsAndServices) {
    const {
        isLastPage,
        isLoading,
        loadNextPage,
        withdrawRequestHistory,
    } = useBalanceWithdrawHistoryOf(user)
    
    const listOfListsOfBalanceTransfers = explitInArraysOf3(withdrawRequestHistory)

    return (
        <div>
            <div class='w-container'>
                <div class='u-marginbottom-20'>
                    <div class='fontsize-base fontweight-semibold'>
                        <I18nText scope='users.balance.withdraw_history_group' />
                    </div>
                </div>
                {listOfListsOfBalanceTransfers.map(transferList => (
                    <div class='u-marginbottom-30 w-row'>
                        {transferList.map((transfer, index) => (
                            <UserBalanceWithdrawHistoryItemRequest transfer={transfer} />
                        ))}
                    </div>
                ))}
                {
                    isLoading ?
                        <Loader />
                        :
                        !isLastPage &&
                        <div class='u-margintop-40 u-marginbottom-80 w-row'>
                            <div class='w-col w-col-5'></div>
                            <div class='w-col w-col-2'>
                                <a href='javascript:void(0);' onclick={loadNextPage} id='load-more' class='btn btn-medium btn-terciary w-button'>
                                    Carregar mais
                                </a>
                            </div>
                            <div class='w-col w-col-5'></div>
                        </div>
                }
            </div>
        </div>
    )
}

function explitInArraysOf3(collection : UserBalanceTransfer[]) : UserBalanceTransfer[][] {
    const array : UserBalanceTransfer[][] = []
    let partArray : UserBalanceTransfer[] = []

    if (collection.length > 3) {

        for (let i = 0; i < collection.length; i++) {

            partArray.push(collection[i])

            if (partArray.length == 3) {
                array.push(partArray)
                partArray = []
            }

        }
        
        if (partArray.length != 3 && partArray.length != 0) {
            array.push(partArray)
        }
    } else {
        array.push(collection)
    }
    
    return array
}