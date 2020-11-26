import { UserBalanceTransfer } from '../../../../../src/root/users/edit/#balance/controllers/use-cases/entities'

export function createUserBalanceTransfers() : UserBalanceTransfer[] {
    return userBalanceTransfers
}

const userBalanceTransfers : UserBalanceTransfer[] = [
    {
        user_id: 11,
        amount: 2000,
        funding_estimated_date: "2020-07-27T12:03:53.793209",
        status: "pending",
        transferred_at: null,
        transferred_date: null,
        requested_in: "2020-07-13T12:03:53.793209",
        user_name: "Astrogildo",
        bank_name: "Caixa Econômica Federal",
        agency: "1233",
        agency_digit: "",
        account: "12383",
        account_digit: "1",
        account_type: "conta_corrente",
        document_type: "cpf",
        document_number: "123456789901"
    }, 
    {
        user_id:11,
        amount:3000,
        funding_estimated_date:"2020-07-10T22:13:18.72236",
        status:"transferred",
        transferred_at:null,
        transferred_date:null,
        requested_in:"2020-06-27T22:13:18.72236",
        user_name:"Astrogildo",
        bank_name:"Banco BM&FBOVESPA; de Serviços de Liquidação e Custódia S.A",
        agency:"1234",
        agency_digit:"",
        account:"12313",
        account_digit:"1",
        account_type:"conta_corrente",
        document_type:"cpf",
        document_number:"123456789901"
    }
]