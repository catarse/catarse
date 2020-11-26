import { withHooks } from 'mithril-hooks'
import { UserBankAccountDisplay } from './user-bank-account-display'
import { I18nText } from '../../../../../../shared/components/i18n-text'
import { Balance, BankAccount } from '../../controllers/use-cases/entities'

export type BankAccountConfirmationProps = {
    bankAccount: BankAccount
    balance: Balance
    goBackToForm(): void
    withdraw(): Promise<void>
}

export const BankAccountConfirmation = withHooks<BankAccountConfirmationProps>(_BankAccountConfirmation)

function _BankAccountConfirmation(props : BankAccountConfirmationProps) {
    const {
        bankAccount,
        balance,
        goBackToForm,
        withdraw,
    } = props

    return (
        <div id='bank-account-confirmation'>
            <div class='modal-dialog-header'>
                <div class='fontsize-large u-text-center'>
                    <I18nText scope='users.balance.withdraw' />
                </div>
            </div>
            <div class='modal-dialog-content u-text-center'>
                <UserBankAccountDisplay bankAccount={bankAccount} balance={balance} />
            </div>
            <div class='modal-dialog-nav-bottom u-margintop-40' style='position: relative;'>
                <div class='w-row'>
                    <div class='w-col w-col-1'></div>
                    <div class='w-col w-col-5'>
                        <a onclick={withdraw} href='javascript:void(0);' class='btn btn-medium btn-request-fund'>
                            <I18nText scope='shared.confirm_text' />
                        </a>
                    </div>
                    <div class='w-col w-col-5'>
                        <a onclick={() => goBackToForm()} href='javascript:void(0);' class='btn btn-medium btn-terciary w-button btn-go-back-to-form' >
                            <I18nText scope='shared.back_text' />
                        </a>
                    </div>
                    <div class='w-col w-col-1'></div>
                </div>
            </div>
        </div>
    )
}
