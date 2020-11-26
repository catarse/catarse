import { BankAccount } from '../../../../../src/root/users/edit/#balance/controllers/use-cases/entities'

export function createBankAccount() : BankAccount {
    return {
        user_id: 1,
        bank_name: 'CEF',
        bank_code: '104',
        account: '8801',
        account_digit: '',
        agency: '778899',
        agency_digit: '1',
        owner_name: 'João Almeida',
        owner_document: '598.630.450-04',
        created_at: new Date().toDateString(),
        updated_at: new Date().toDateString(),
        bank_account_id: null,
        bank_id: 1,
        account_type: 'cpf',
    }
}