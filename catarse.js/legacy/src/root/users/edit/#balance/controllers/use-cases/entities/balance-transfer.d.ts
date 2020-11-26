export type UserBalanceTransfer = {
    account: string
    account_digit: string
    account_type: BankAccountType
    agency: string
    agency_digit: string
    amount: number
    bank_name: string
    document_number: string
    document_type: 'cpf' | 'cnpj' | 'mei' | 'cnpj_mei'
    funding_estimated_date: string
    requested_in: string
    status: string
    transferred_at: string | null
    transferred_date: string | null
    user_id: number
    user_name: string
}

export type BankAccountType = 'conta_poupanca' | 'conta_corrente' | 'conta_corrente_conjunta' | 'conta_poupanca_conjunta'