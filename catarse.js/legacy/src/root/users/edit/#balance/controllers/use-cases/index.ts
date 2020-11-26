import h from '../../../../../../h'
import { catarse } from '../../../../../../api'
import models from '../../../../../../models'
import { httpPutRequest, filterFactory } from '../../../../../../shared/services'

import { LoadUserBankAccount, createUserBankAccountLoader, EmptyBankAccount } from './load-user-bank-account'
import { LoadBanks, createBanksLoader } from './load-banks'
import { UpdateUserBankAccount, createUserBankAccountUpdater } from './update-user-bank-account'
import { LoadUserBalance, createUserBalanceLoader } from './load-user-balance'
import { LoadUserBalanceTransactions, createUserBalanceTransactionLoader } from './load-user-balance-transactions'
import { LoadUserWithdrawRequestHistory, createUserWithdrawRequestHistoryLoader } from './load-user-withdraw-request-history'
import { WithdrawFunds, createWithdrawRequest } from './withdraw-funds'

export type {
    WithdrawFunds,
    LoadUserBankAccount,
    LoadBanks,
    UpdateUserBankAccount,
    LoadUserBalance,
    LoadUserBalanceTransactions,
    LoadUserWithdrawRequestHistory,
}

export {
    EmptyBankAccount
}

export const withdrawFunds = createWithdrawRequest({
    api: catarse,
    balanceTransfer: models.balanceTransfer,
})
export const loadUserBankAccount = createUserBankAccountLoader({ 
    api: catarse, 
    bankAccount: models.bankAccount, 
    redraw: h.redraw,
    filter: filterFactory(),
})
export const loadBanks = createBanksLoader({
    loadBanks: () => catarse.loader(models.bank.getPageOptions()).load(),
    redraw: h.redraw
})
export const updateUserBankAccount = createUserBankAccountUpdater({
    httpPutRequest,
    redraw: h.redraw
})
export const loadUserBalance = createUserBalanceLoader({
    filter: filterFactory(),
    balance: models.balance,
    redraw: h.redraw
})
export const loadUserBalanceTransactions = createUserBalanceTransactionLoader({
    api: catarse,
    filter: filterFactory(),
    model: models.balanceTransaction,
    redraw: h.redraw
})
export const loadUserWithdrawHistory = createUserWithdrawRequestHistoryLoader({
    api: catarse,
    filter: filterFactory(),
    userBalanceTransfers: models.userBalanceTransfers,
    redraw: h.redraw
})