import moment from 'moment'
import h from '../../../../../h'
import { UserBalanceWithdrawRequestWithServices } from './user-balance-withdraw-request'
import { Modal } from '../../../../../shared/components/modal'
import { Balance, UserId } from '../controllers/use-cases/entities'
import { withHooks, useState, useMemo } from 'mithril-hooks'
import { Loader } from '../../../../../shared/components/loader'
import { I18nText } from '../../../../../shared/components/i18n-text'
import { UserDetails } from '../../../../../entities'

export type UserBalanceAmountProps = {
    user: UserDetails
}

export type UserBalanceAmountServices = {
    useBalanceAmountOf(user : UserId) : { isLoading : boolean, balance : Balance }
}

type UserBalanceAmountPropsAndServices = UserBalanceAmountProps & UserBalanceAmountServices

export const UserBalanceAmount = withHooks<UserBalanceAmountPropsAndServices>(_UserBalanceAmount)

function _UserBalanceAmount({ user, useBalanceAmountOf } : UserBalanceAmountPropsAndServices) {

    const {
        isLoading,
        balance,
    } = useBalanceAmountOf(user)

    const [ displayModal, setDisplayModal ] = useState(false)
    
    if (isLoading) {
        return (
            <Loader />
        )
    } else {

        const positiveValue = balance.amount >= 0
        const canMakeWithdrawRequest = !!balance && balance.amount > 0 && !balance.in_period_yet && !balance.has_cancelation_request
        const onClickCTA = canMakeWithdrawRequest ? (() => setDisplayModal(true)) : (() => {})
        
        return (
            <div class='w-section section user-balance-section'>
                {
                    displayModal &&
                    <Modal onClose={() => setDisplayModal(false)}>
                        <UserBalanceWithdrawRequestWithServices 
                            user={user}
                            balance={balance}
                        />
                    </Modal>
                }
                <div class='w-container'>
                    <div class='card card-terciary u-radius w-row'>
                        <div class='w-col w-col-8 u-text-center-small-only u-marginbottom-20'>
                            <div class='fontsize-larger'>
                                <I18nText scope='users.balance.totals' />
                                <span class={`text-${positiveValue ? 'success' : 'error'}`}>
                                    R$ {h.formatNumber(balance?.amount || 0, 2, 3)}
                                </span>
                            </div>
                        </div>
                        <div class='w-col w-col-4'>
                            <a onclick={onClickCTA} href='javascript:void(0);' class={`r-fund-btn w-button btn btn-medium u-marginbottom-10 ${canMakeWithdrawRequest ? '' : 'btn-inactive'} btn-withdraw-request-process-start`}>
                                <I18nText scope='users.balance.withdraw_cta' />
                            </a>
                            <div class='fontsize-smaller fontweight-semibold'>
                                <BalanceWithdrawStatus balance={balance} />
                            </div>
                            <div class='fontcolor-secondary fontsize-smallest lineheight-tight'>
                                <BalanceWithdrawMessage balance={balance} />
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        )
    }
}

type BalanceProps = {
    balance : Balance
}

const BalanceWithdrawStatus = withHooks<BalanceProps>(_BalanceWithdrawStatus)

function _BalanceWithdrawStatus({ balance } : BalanceProps) {
    if (balance.has_cancelation_request) {
        return (
            <I18nText scope='users.balance.withdraw_canceling_title' />
        )
    } else if (balance.last_transfer_amount && balance.in_period_yet) {
        return (
            <I18nText 
                scope='users.balance.last_withdraw_msg' 
                params={{
                    amount: `R$ ${h.formatNumber(balance.last_transfer_amount, 2, 3)}`,
                    date: moment(balance.last_transfer_created_at).format('MMMM')
                }} />
        )
    } else {
        return (
            <I18nText
                scope='users.balance.no_withdraws_this_month'
                params={{
                    month_name: moment().format('MMMM')
                }} />
        )
    }
}

const BalanceWithdrawMessage = withHooks<BalanceProps>(_BalanceWithdrawMessage)

function _BalanceWithdrawMessage({ balance } : BalanceProps) {
    if (balance.has_cancelation_request) {
        return (
            <I18nText scope='users.balance.withdraw_canceling_msg' />
        )
    } else {
        return (
            <I18nText scope='users.balance.withdraw_limits_msg' />
        )
    }
}