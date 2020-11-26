import { ViewModel } from '../../../../../../entities'
import { UserBalanceTransfer, UserId } from './entities'
import { Filter, Equal } from '../../../../../../shared/services'

export type LoadUserWithdrawRequestHistory = (user : UserId) => ViewModel<UserBalanceTransfer>

export type BuildParams = {
    api: {
        paginationVM(model : Model, orderParams : 'requested_in.desc', addonsHeader : { Prefer: 'count=exact'}) : ViewModel<UserBalanceTransfer>
    }
    filter: Filter
    userBalanceTransfers: Model
    redraw(): void
}

type Model = {
    getRowWithToken(params? : {}) : Promise<UserBalanceTransfer[]>
    pageSize(size : number)
}

export function createUserWithdrawRequestHistoryLoader(params : BuildParams) : LoadUserWithdrawRequestHistory {

    const {
        api,
        userBalanceTransfers,
        filter,
        redraw,
    } = params
    
    return (user : UserId) : ViewModel<UserBalanceTransfer> => {
        userBalanceTransfers.pageSize(3)
        filter.setParam('user_id', Equal(user.id))
        const listVM = api.paginationVM(userBalanceTransfers, 'requested_in.desc', { Prefer: 'count=exact' });
    
        listVM.firstPage(filter.toParameters()).then(redraw).catch(redraw)
    
        return {
            ...listVM,
            async nextPage() : Promise<UserBalanceTransfer[]> {
                try {
                    await listVM.nextPage()
                    return listVM.collection()
                } catch(e) {
                    redraw()
                } finally {
                    redraw()
                }
            }
        }
    }
}