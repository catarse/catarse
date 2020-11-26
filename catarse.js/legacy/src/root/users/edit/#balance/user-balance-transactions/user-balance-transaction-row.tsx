import { withHooks, useState } from 'mithril-hooks'
import { BalanceTransactionSource, BalanceTransaction } from '../controllers/use-cases/entities'
import { I18nText } from '../../../../../shared/components/i18n-text'
import { DateFormat } from '../../../../../shared/components/date-format'
import { CurrencyFormat } from '../../../../../shared/components/currency-format'

export type UserBalanceTransactionRowProps = {
    index: number
    transaction: BalanceTransaction
}

export const UserBalanceTransactionRow = withHooks<UserBalanceTransactionRowProps>(_UserBalanceTransactionRow)

function _UserBalanceTransactionRow(props : UserBalanceTransactionRowProps) {
    
    const { index, transaction } = props
    const [ expanded, setExpanded ] = useState(index === 0)
    const transactionSources = transaction?.source?.filter(source => !!source)
    
    return (
        <div onclick={() => setExpanded(!expanded)} class={`balance-card ${expanded ? 'card-detailed-open' : ''}`}>
            <div class='w-clearfix card card-clickable'>
                <div class='w-row'>
                    <div class='w-col w-col-2 w-col-tiny-2'>
                        <div class='fontsize-small lineheight-tightest'>
                            <DateFormat date={transaction.created_at} format='D MMM' />
                        </div>
                        <div class='fontsize-smallest fontcolor-terciary'>
                            <DateFormat date={transaction.created_at} format='YYYY' />
                        </div>
                    </div>
                    <div class='w-col w-col-10 w-col-tiny-10'>
                        <div class='w-row'>
                            <div class='w-col w-col-4'>
                                <div>
                                    <span class='fontsize-smaller fontcolor-secondary'>
                                        <I18nText scope='users.balance.debit' />
                                    </span>
                                    &nbsp;
                                    <span class='fontsize-base text-error'>
                                        <CurrencyFormat label='R$' value={transaction.debit} />
                                    </span>
                                </div>
                            </div>
                            <div class='w-col w-col-4'>
                                <div>
                                    <span class='fontsize-smaller fontcolor-secondary'>
                                        <I18nText scope='users.balance.credit' />
                                    </span>
                                    &nbsp;
                                    <span class='fontsize-base text-success'>
                                        <CurrencyFormat label='R$' value={transaction.credit} />
                                    </span>
                                </div>
                            </div>
                            <div class='w-col w-col-4'>
                                <div>
                                    <span class='fontsize-smaller fontcolor-secondary'>
                                        <I18nText scope='users.balance.totals' />
                                    </span>
                                    &nbsp;
                                    <span class='fontsize-base'>
                                        <CurrencyFormat label='R$' value={transaction.total_amount} />
                                    </span>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
                <a href='javascript:(void(0));' class={`${expanded ? 'arrow-admin-opened' : ''} w-inline-block arrow-admin fa fa-chevron-down fontcolor-secondary`}></a>
            </div>
            {
                expanded &&
                <div class='card'>
                    {transactionSources.map(transaction => (
                        <Transaction transaction={transaction} />
                    ))}
                </div>
            }
        </div>
    )
}

type TransactionProps = {
    transaction: BalanceTransactionSource
}

const Transaction = withHooks<TransactionProps>(_Transaction)

function _Transaction({ transaction } : TransactionProps) {
    const positive = transaction.amount >= 0
    const event_data = {
        subscription_reward_label: transaction.origin_objects.subscription_reward_label || '',
        subscriber_name: transaction.origin_objects.subscriber_name,
        service_fee: transaction.origin_objects.service_fee ? formatToNearestFraction(Number(transaction.origin_objects.service_fee) * 100.0) : '',
        project_name: transaction.origin_objects.project_name,
        contributitor_name: transaction.origin_objects.contributor_name,
        from_user_name: transaction.origin_objects.from_user_name,
        to_user_name: transaction.origin_objects.to_user_name,
    }

    return (
        <div>
            <div class='w-row fontsize-small u-marginbottom-10'>
                <div class='w-col w-col-2'>
                    <div class={`text-${positive ? 'success' : 'error'}`}>
                        {positive ? '+' : '-'}
                        &nbsp;
                        <CurrencyFormat label='R$' value={Math.abs(transaction.amount)} />
                    </div>
                </div>
                <div class='w-col w-col-10'>
                    <I18nText 
                        scope={`users.balance.event_names.${transaction.event_name}`}
                        params={event_data} 
                        trust={transaction.event_name === 'balance_expired'} />
                </div>
            </div>
            <div class='divider u-marginbottom-10'></div>
        </div>
    )
}

function formatToNearestFraction(n : number, precision : number = 3) {
    const nString = `${n.toFixed(precision)}`.split('').reverse().join('').replace(/^0+(.*)\./g, '$1\.')
    if (nString.charAt(0) === '\.') {
        return nString.substring(1).split('').reverse().join('')
    } else {
        return nString.split('').reverse().join('')
    }
}