import { withHooks } from 'mithril-hooks'
import { UserBalanceAmount, UserBalanceAmountProps } from './user-balance-amount/user-balance-amount'
import { UserBalanceTransactionsWithServices } from './user-balance-transactions'
import { UserBalanceWithdrawHistoryWithServices } from './user-balance-withdraw-history'
import { UserDetails } from '@/entities'
import { UserBalanceAmountWithServices } from './user-balance-amount'
import { I18nText } from '@/shared/components/i18n-text'

export type UserBalanceProps = {
    user: UserDetails
}

export const UserBalance = withHooks<UserBalanceProps>(_UserBalance)

function _UserBalance({user} : UserBalanceProps) {
    return (
        <div id='balance-area'>
            <IrrfRetentionMessage user={user}/>
            <UserBalanceAmountWithServices user={user} />
            <UserBalanceWithdrawHistoryWithServices user={user} />
            <div class='divider'></div>
            <UserBalanceTransactionsWithServices user={user} />
            <div class='u-marginbottom-40'></div>
            <div class='w-section section card-terciary before-footer'></div>
        </div>
    )
}

const IrrfRetentionMessage = withHooks<UserBalanceProps>(_IrrfRetentionMessage)

function _IrrfRetentionMessage({user}: UserBalanceProps) {
    if (user.account_type === 'pj' || user.account_type === 'mei') {
        return (
            <div class="w-container">
                <div class="card card-message u-radius fontsize-small">
                    <I18nText scope="users.balance.withdraw_irrf_message_html" trust={true}/>
                </div>
            </div>
        )
    }
}
