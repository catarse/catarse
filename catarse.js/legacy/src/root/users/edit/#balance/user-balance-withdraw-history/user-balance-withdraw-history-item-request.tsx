import m from 'mithril'
import _ from 'underscore'
import h from '../../../../../h'
import { withHooks } from 'mithril-hooks'
import { I18nText } from '../../../../../shared/components/i18n-text'
import { DateFormat } from '../../../../../shared/components/date-format'
import { DocumentFormat } from '../../../../../shared/components/document-format'
import { UserBalanceTransfer } from '../controllers/use-cases/entities'

export type UserBalanceWithdrawHistoryItemRequestProps = {
    transfer: UserBalanceTransfer
}

export const UserBalanceWithdrawHistoryItemRequest = withHooks<UserBalanceWithdrawHistoryItemRequestProps>(_UserBalanceWithdrawHistoryItemRequest)

function _UserBalanceWithdrawHistoryItemRequest(props : UserBalanceWithdrawHistoryItemRequestProps) {

    const { transfer } = props
    const cardStatusClass = cardStatusClassMap[transfer.status]
    const cardInfoStatusClass = cardInfoStatusClassMap[transfer.status]

    return (
        <div class='u-marginbottom-20 w-col w-col-4'>
            <div class={`card u-radius ${cardStatusClass}`}>
                <div>
                    <div class='fontsize-small'>
                        <strong>
                            <I18nText scope='users.balance.transfer_labels.amount' />
                        </strong>
                        R$ {h.formatNumber(transfer.amount || 0, 2, 3)}
                        <br/>
                    </div>
                    <div class='fontsize-smaller u-marginbottom-20'>
                        <strong>
                            <I18nText scope='users.balance.transfer_labels.requested_in' />
                        </strong>
                        <DateFormat date={transfer.requested_in} format='DD/MM/YYYY' />
                        <br/>
                    </div>
                </div>
                <div class='fontsize-smallest'>
                    <strong>
                        <I18nText scope='users.balance.bank.bank_name' />
                    </strong>
                    {transfer.bank_name}
                    <br/>
                    <strong>
                        <I18nText scope='users.balance.bank.agency' />
                    </strong>
                    {transfer.agency}{transfer.agency_digit ? '-' + transfer.agency_digit : ''}
                    <br/>
                    <strong>
                        <I18nText scope='users.balance.bank.account' />
                    </strong>
                    {transfer.account}{transfer.account_digit ? '-' + transfer.account_digit : ''}
                    <br/>
                    <strong>
                        <I18nText scope='users.balance.bank.account_type_name' />
                    </strong>
                    <I18nText scope={`users.balance.bank.account_type.${transfer.account_type}`} />
                    <br/>
                    <strong>
                        <I18nText scope='users.balance.transfer_labels.user_name' />
                    </strong>
                    {transfer.user_name}
                    <br/>
                    <strong>
                        <I18nText scope={`users.balance.bank.${transfer.document_type}`} />
                    </strong>
                    <DocumentFormat number={transfer.document_number} type={transfer.document_type} />
                </div>
                <div class={`fontsize-smaller u-text-center badge fontweight-semibold u-margintop-30 ${cardInfoStatusClass}`}>
                    <CardInfo transfer={transfer} />
                </div>
            </div>
        </div>
    )
}

const cardStatusClassMap = {
    pending: 'card-alert',
    authorized: 'card-alert',
    processing: 'card-alert',

    error: 'card-alert',
    gateway_error: 'card-alert',
    rejected: 'card-alert',

    transferred: 'card-greenlight'
}

const cardInfoStatusClassMap = {
    pending: 'badge-attention',
    authorized: 'badge-attention',
    processing: 'badge-attention',

    error: 'card-error',
    gateway_error: 'card-error',
    rejected: 'card-error',

    transferred: 'badge-success'
}

type CardInfoProps = {
    transfer: UserBalanceTransfer
}

const CardInfo = withHooks<CardInfoProps>(_CardInfo)

function _CardInfo({ transfer } : CardInfoProps) {

    const CardInfoComponent = CardInfoComponentMap[transfer.status]

    return (
        <CardInfoComponent {...transfer} />
    )
}

const CardInfoStarter = withHooks<{ funding_estimated_date : string }>(_CardInfoStarter)

function _CardInfoStarter(props : { funding_estimated_date : string }) {
    const {
        funding_estimated_date
    } = props
    return (
        <>
            <span class='fa fa-clock-o'> </span>
            <I18nText scope='users.balance.transfer_labels.funding_estimated_date' />
            <DateFormat date={funding_estimated_date} format='DD/MM/YYYY' />
            <br/>
        </>
    )
}

const CardInfoError = withHooks(_CardInfoError)

function _CardInfoError() {
    const contactUrl = 'https://suporte.catarse.me/hc/pt-br/signin?return_to=https%3A%2F%2Fsuporte.catarse.me%2Fhc%2Fpt-br%2Frequests%2Fnew&amp;locale=19'
    const preScope = 'users.balance.transfer_labels'
    return (
        <>
            <span class='fa fa-exclamation-circle'> </span>
            <I18nText scope={`${preScope}.transfer_error`} />
            <br/>
            <I18nText scope={`${preScope}.transfer_error_line1`} />
            <a href={contactUrl} target='_blank' class='link-hidden-white'>
                <I18nText scope={`${preScope}.transfer_error_line2`} />
            </a>
            <I18nText scope={`${preScope}.transfer_error_line3`} />
            <a href='#' class='link-hidden-white'></a>
            <br/>
        </>
    )
}

const CardInfoSuccess = withHooks<{ transferred_at : string }>(_CardInfoSuccess)

function _CardInfoSuccess({ transferred_at } : { transferred_at : string }) {
    const preScope = 'users.balance.transfer_labels'
    return (
        <>
            <span class='fa fa-check-circle'> </span>
            <I18nText scope={`${preScope}.received_at`} />
            <DateFormat date={transferred_at} format='DD/MM/YYYY' />
            <br/>
        </>
    )
}

const CardInfoComponentMap = {
    pending: CardInfoStarter,
    authorized: CardInfoStarter,
    processing: CardInfoStarter,
    error: CardInfoError,
    gateway_error: CardInfoError,
    rejected: CardInfoError,
    transferred: CardInfoSuccess
}