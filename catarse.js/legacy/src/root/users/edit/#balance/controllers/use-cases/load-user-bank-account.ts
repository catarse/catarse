import { UserDetails } from '../../../../../../entities'
import { Filter, Equal } from '../../../../../../shared/services'
import { BankAccount, UserId } from './entities'

export type LoadUserBankAccount = (user : UserDetails) => Promise<BankAccount>

type BuildParams = {
    filter: Filter
    api: {
        loaderWithToken(params : {}) : {
            load(): Promise<BankAccount[]>
        }
    }
    bankAccount: Model,
    redraw(): void
}

type Model = {
    getPageOptions(params? : { [field:string] : string }) : {}
}

export function createUserBankAccountLoader(params : BuildParams) : LoadUserBankAccount {
    const {
        api,
        bankAccount,
        filter,
        redraw,
    } = params

    return async function (user : UserDetails) : Promise<BankAccount> {
        filter.setParam('user_id', Equal(user.id))
        const configOptions = bankAccount.getPageOptions(filter.toParameters())
        
        try {
            const userBankAccountAsArray = await api.loaderWithToken(configOptions).load() as BankAccount[]
            const hasBankAccount = userBankAccountAsArray && userBankAccountAsArray.length >= 1
            if (hasBankAccount) {
                return userBankAccountAsArray[0]
            } else {
                return {
                    ...EmptyBankAccount,
                    user_id: user.id,
                    owner_name: user.name,
                    owner_document: user.owner_document,
                } as BankAccount
            }
        } catch(e) {
            return {
                ...EmptyBankAccount,
                user_id: user.id,
                owner_name: user.name,
                owner_document: user.owner_document,
            } as BankAccount
        } finally {
            redraw()
        }  
    }
}

export const EmptyBankAccount : BankAccount = {
    account: '',
    account_digit: '',
    account_type: 'conta_corrente',
    agency: '',
    agency_digit: '',
    bank_code: '',
    bank_id: undefined,
    bank_account_id: null,
    bank_name: '',
    created_at: null,
    owner_document: '',
    owner_name: '',
    updated_at: null,
    user_id: null,
}