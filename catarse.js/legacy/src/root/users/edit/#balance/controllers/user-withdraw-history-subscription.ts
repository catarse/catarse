export type UserBalanceTransactionsSubscription = {
    subscribe(reload : () => void): void
}

export type UserBalanceTransactionsSubject = {
    next(): void
}