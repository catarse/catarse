import { UserId, Balance } from './entities'
import { Filter, Equal } from '../../../../../../shared/services'

export type LoadUserBalance = (user : UserId) => Promise<Balance>

export type BuildParams = {
    filter: Filter
    balance: {
        getRowWithToken(params : { [field:string] : string }) : Promise<Balance[]>
    }
    redraw(): void
}

export function createUserBalanceLoader(params : BuildParams) : LoadUserBalance {
    return async (user : UserId) : Promise<Balance> => {
        const {
            filter,
            balance,
            redraw,
        } = params
        
        const defaultBalance : Balance = {
            user_id: Number(user.id),
            amount: 0,
            last_transfer_amount: 0,
            last_transfer_created_at: null,
            in_period_yet: true,
            has_cancelation_request: false
        }

        filter.setParam('user_id', Equal(user.id))

        try {
            const balancesArray = await balance.getRowWithToken(filter.toParameters())
    
            if (balancesArray && balancesArray.length > 0) {
                return { ...balancesArray[0] }
            } else {
                return defaultBalance
            }
        } catch(e) {
            return defaultBalance
        } finally {
            redraw()
        }
    }
}