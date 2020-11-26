import { Subject } from 'rxjs'
import { UserBalanceTransactionsSubject, UserBalanceTransactionsSubscription } from '../user-withdraw-history-subscription'

const subject = new Subject<any>()

export const userBalanceTransactionsSubscription : UserBalanceTransactionsSubscription = {
    subscribe: subject.subscribe.bind(subject)
}

export const userBalanceTransactionsSubject : UserBalanceTransactionsSubject = {
    next: subject.next.bind(subject)
}