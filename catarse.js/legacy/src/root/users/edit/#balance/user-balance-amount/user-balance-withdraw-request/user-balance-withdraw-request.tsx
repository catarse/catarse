
import { WithdrawRequestForm } from './withdraw-request-form'
import { withHooks } from 'mithril-hooks'
import { BankAccountConfirmation } from './bank-account-confirmation'
import { WithdrawRequestDone } from './withdraw-request-done'
import { Loader } from '../../../../../../shared/components/loader'
import { Balance, BankAccount, Bank } from '../../controllers/use-cases/entities'
import { UserDetails } from '../../../../../../entities/user-details'
import { WithdrawRequestStage } from '../../controllers/use-cases/entities/withdraw-request-stage'

export type UserBalanceRequestProps = {
    user: UserDetails
    balance: Balance
}

export type UserBalanceRequestServices = {
    useWithdrawRequestFor(user : UserDetails): {
        stage: WithdrawRequestStage
        bankAccount: BankAccount
        banks: Bank[]
        getErrors(field : string): string[]
        isLoading: boolean
        manualBankCode: string
        setManualBankCode(newManualBankCode : string): void
        setBankAccount(newBankAccount : BankAccount): void
        withdraw(): Promise<void>
        bankAccountUpdate(): Promise<void>
        goBackToForm(): void
    }
}

type UserBalanceRequestPropAndServices = UserBalanceRequestProps & UserBalanceRequestServices

export const UserBalanceWithdrawRequest = withHooks<UserBalanceRequestPropAndServices>(_UserBalanceWithdrawRequest)

function _UserBalanceWithdrawRequest({user, balance, useWithdrawRequestFor} : UserBalanceRequestPropAndServices) {

    const {
        stage,
        bankAccount,
        banks,
        getErrors,
        isLoading,
        manualBankCode,
        setManualBankCode,
        setBankAccount,
        withdraw,
        bankAccountUpdate,
        goBackToForm,
    } = useWithdrawRequestFor(user)

    if (isLoading) {
        return (
            <Loader />
        )
    }

    switch(stage) {
        case WithdrawRequestStage.FILL_FORM: {
            return (
                <WithdrawRequestForm
                    user={user}
                    balance={balance}
                    bankAccount={bankAccount}
                    onChange={setBankAccount}
                    manualBankCode={manualBankCode}
                    onChangeManualBankCode={setManualBankCode}
                    banks={banks}
                    getErrors={getErrors}
                    bankAccountUpdate={bankAccountUpdate}
                />
            )
        }

        case WithdrawRequestStage.CONFIRM_BANK_ACCOUNT: {
            return (
                <BankAccountConfirmation
                    bankAccount={bankAccount}
                    balance={balance}
                    goBackToForm={goBackToForm}
                    withdraw={withdraw}
                />
            )
        }

        case WithdrawRequestStage.SUCCESS: {
            return (
                <WithdrawRequestDone />
            )
        }

        default: {
            return (
                <WithdrawRequestForm
                    user={user}
                    balance={balance}
                    bankAccount={bankAccount}
                    onChange={setBankAccount}
                    manualBankCode={manualBankCode}
                    onChangeManualBankCode={setManualBankCode}
                    banks={banks}
                    getErrors={getErrors}
                    bankAccountUpdate={bankAccountUpdate}
                />
            )
        }
    }
}