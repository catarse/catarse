import { UserId, BankAccount } from './entities'
import { HttpPutRequest } from '../../../../../../shared/services'

export type UpdateUserBankAccount = (user : UserId, bankAccount : BankAccount) => Promise<void>

type BuildParams = {
    httpPutRequest: HttpPutRequest
    redraw(): void
}

export function createUserBankAccountUpdater(params : BuildParams) : UpdateUserBankAccount {
    const {
        httpPutRequest,
        redraw,
    } = params

    return async (user : UserId, bankAccount : BankAccount) => {
        const updateUserData = {
            bank_account_attributes: {
                bank_id: bankAccount.bank_id,
                // THIS is just bank code, inserted manually, it MUST be empty when
                // updating bank account with bank_id, otherwise it will update with
                // user bank account loaded and not the new one set.
                input_bank_number: bankAccount.bank_code, 
                agency_digit: bankAccount.agency_digit,
                agency: bankAccount.agency,
                account: bankAccount.account,
                account_digit: bankAccount.account_digit,
                account_type: bankAccount.account_type,
                ...(
                    bankAccount.bank_account_id ? 
                        {
                            id: bankAccount.bank_account_id
                        }
                        :
                        {}
                )
            }
        }

        const url = `/users/${user.id}.json`
        await httpPutRequest(url, {}, { user : updateUserData }, 'text')
        redraw()
    }
}