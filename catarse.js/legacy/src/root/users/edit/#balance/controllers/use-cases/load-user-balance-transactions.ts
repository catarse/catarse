import { ViewModel } from '../../../../../../entities'
import { BalanceTransaction, UserId } from './entities'
import { Filter, Equal } from '../../../../../../shared/services'

export type LoadUserBalanceTransactions = (user : UserId) => ViewModel<BalanceTransaction>

type BuildParams = {
    api: {
        paginationVM(model : Model, orderParams : 'created_at.desc') : ViewModel<BalanceTransaction>
    }
    filter: Filter
    model: Model,
    redraw(): void
}

type Model = {
    getRowWithToken(params : { [field:string] : string | number }) : Promise<BalanceTransaction[]>
}

export function createUserBalanceTransactionLoader(params : BuildParams) : LoadUserBalanceTransactions {

    const {
        api,
        filter,
        model,
        redraw,
    } = params

    return (user : UserId) : ViewModel<BalanceTransaction> => {

        try {
            filter.setParam('user_id', Equal(user.id))
    
            const listVM = api.paginationVM(model, 'created_at.desc');
        
            listVM.firstPage(filter.toParameters()).then(redraw).catch(redraw)
        
            return {
                ...listVM,
                async nextPage() : Promise<BalanceTransaction[]> {
                    try {
                        await listVM.nextPage()
                        return listVM.collection()
                    } catch(error) {
                        console.log('Error loading balance transactions:', error.message)
                        redraw()
                    } finally {
                        redraw()
                    }
                }
            }
        } catch(error) {
            console.log('Error creating LoadUserBalanceTransactions:', error.message)
        } finally {
            redraw()
        }
    }
}