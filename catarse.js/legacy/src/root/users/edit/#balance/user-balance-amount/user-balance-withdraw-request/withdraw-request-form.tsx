import { withHooks } from 'mithril-hooks'
import { UserDetails } from '../../../../../../entities'
import { Balance, BankAccount, Bank } from '../../controllers/use-cases/entities'
import { UserOwnerBox } from './user-owner-box'
import { UserBankForm } from './user-bank-form'
import { I18nText } from '../../../../../../shared/components/i18n-text'
import { CardRounded } from '../../../../../../shared/components/card-rounded'
import h from '../../../../../../h'
import { CurrencyFormat } from '../../../../../../shared/components/currency-format'

export type WithdrawRequestFormProps = {
    user: UserDetails
    balance: Balance
    bankAccount: BankAccount
    onChange(bankAccount : BankAccount): void
    manualBankCode: string
    onChangeManualBankCode(bankCode : string): void
    banks: Bank[]
    getErrors(field : string): string[]
    bankAccountUpdate(): Promise<void>
}

export const WithdrawRequestForm = withHooks<WithdrawRequestFormProps>(_WithdrawRequestForm)

function _WithdrawRequestForm(props : WithdrawRequestFormProps) {
    const {
        user,
        balance,
        bankAccount,
        onChange,
        manualBankCode,
        onChangeManualBankCode,
        banks,
        getErrors,
        bankAccountUpdate,
    } = props

    const validationError = getErrors('validation_error')
    const hasValidationError = validationError.length > 0

    return (
        <div id='withdraw-request-form'>
            <div class='modal-dialog-header'>
                <div class='fontsize-large u-text-center'>
                    <I18nText scope='users.balance.withdraw' />
                </div>
            </div>
            <div class='modal-dialog-content'>
                <div class='fontsize-base u-marginbottom-20'>
                    <span class='fontweight-semibold'>
                        <I18nText scope='users.balance.value_text' />:&nbsp;
                    </span>
                    <span class='text-success'>
                        <CurrencyFormat label='R$' value={balance.amount} />
                    </span>
                </div>
                <UserOwnerBox
                    user={user}
                    hideAvatar={true}
                    getErrors={getErrors}
                    />
                <UserBankForm
                    getErrors={getErrors}
                    bankAccount={bankAccount}
                    onChange={onChange}
                    banks={banks}
                    manualBankCode={manualBankCode}
                    onChangeManualBankCode={onChangeManualBankCode}
                    />
            </div>
            <div class='modal-dialog-nav-bottom' style='position: relative;'>
                {
                    hasValidationError &&
                    <CardRounded className='card-error u-marginbottom-20'>
                        {validationError.map((message : string) => (
                            <span>
                                {message}
                            </span>
                        ))}
                    </CardRounded>
                }
                <div class='w-row'>
                    <div class='w-col w-col-3'></div>
                    <div class='w-col w-col-6'>
                        <a onclick={(event : Event) => {
                            event.preventDefault()
                            bankAccountUpdate()
                        }} class='btn btn-large btn-request-fund'>
                            <I18nText scope='users.balance.request_fund' />
                        </a>
                    </div>
                    <div class='w-col w-col-3'></div>
                </div>
            </div>
        </div>
    )
}
