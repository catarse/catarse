import { useState, useEffect, useMemo, useLayoutEffect, MithrilHooks } from 'mithril-hooks'
import { BankAccount, Bank, UserId } from './use-cases/entities'
import { ErrorsViewModel, FieldMapper } from '../../../../../shared/services'
import { LoadBanks, LoadUserBankAccount, UpdateUserBankAccount, WithdrawFunds, EmptyBankAccount } from './use-cases'
import { WithdrawRequestStage } from './use-cases/entities/withdraw-request-stage'
import { UserBalanceTransactionsSubject } from './user-withdraw-history-subscription'
import { UserDetails, ThisWindow } from '../../../../../entities'

declare var window : ThisWindow

export type UseWithdrawRequestForDependencies = {
    loadBanks: LoadBanks
    loadUserBankAccount: LoadUserBankAccount
    updateUserBankAccount: UpdateUserBankAccount
    withdrawFunds: WithdrawFunds
    updateSubject: UserBalanceTransactionsSubject
}

const FieldMapperBankAccount : FieldMapper = {
    from(field : string) {
        if (field.includes('bank_account')) {
            const bankAccountField = field.split('.')[1]
            return bankAccountField
        } else {
            return field
        }
    }
}

export function useWithdrawRequestFor(user : UserDetails, deps : UseWithdrawRequestForDependencies) : UseWithdrawRequestForReturn {

    const errorsVM = useMemo(() => new ErrorsViewModel(FieldMapperBankAccount), [])
    const [ banks, setBanks ] = useState<Bank[]>([])
    const [ bankAccount, setBankAccount ] = useState<BankAccount>(bankAccountWithUserDocumentAndName(EmptyBankAccount, user))
    const [ manualBankCode, setManualBankCode ] = useState('')
    const [ isLoading, setIsLoading ] = useState(true)
    const [ stage, setStage ] = useState(WithdrawRequestStage.FILL_FORM)

    const hadleUserBankAccountUpdate = async (user : UserDetails, bankAccount : BankAccount) => {
        try {
            setIsLoading(true)
            errorsVM.clearErrors()
            const bankAccountFilled = { ...bankAccount, bank_code: !!manualBankCode ? manualBankCode : bankAccount.bank_code }
            if (!bankAccountFilled.bank_id) {
                throw new Error(JSON.stringify({
                    errors_json: JSON.stringify({
                        bank_id: window.I18n.t('bank_accounts.edit.select_bank', {} as any)
                    })
                }))
            }
            await deps.updateUserBankAccount(user, bankAccountFilled)
            setBankAccount(bankAccountWithUserDocumentAndName(bankAccountFilled, user))
            setStage(WithdrawRequestStage.CONFIRM_BANK_ACCOUNT)
        } catch(e) {
            const parsed_error = JSON.parse(e.message)
            const error = parsed_error as { errors_json : string }
            errorsVM.setErrors(error.errors_json)
        } finally {
            setIsLoading(false)
        }
    }

    const handleWithdrawFunds = async (user : UserId) => {
        try {
            setIsLoading(true)
            errorsVM.clearErrors()
            await deps.withdrawFunds(user)
            deps.updateSubject.next()
            setStage(WithdrawRequestStage.SUCCESS)
        } catch(e) {
            const parsed_error = JSON.parse(e.message)
            const error = parsed_error as { errors_json : string }
            errorsVM.setErrors(error.errors_json)
        } finally {
            setIsLoading(false)
        }
    }

    useEffect(() => {
        setStage(WithdrawRequestStage.FILL_FORM)
        const bankAccountLoader = async () => setBankAccount((await deps.loadUserBankAccount(user)) || bankAccountWithUserDocumentAndName(EmptyBankAccount, user))
        const banksLoader = async () => setBanks(await deps.loadBanks())
        
        const banksAndAccount = async () => {
            setIsLoading(true)
            await bankAccountLoader()
            await banksLoader()
            setIsLoading(false)
        }
        banksAndAccount()
    }, [])

    return {
        stage,
        isLoading,
        async bankAccountUpdate() {
            await hadleUserBankAccountUpdate(user, bankAccount)
        },
        async withdraw() {            
            await handleWithdrawFunds(user)
        },
        banks,
        manualBankCode,
        setManualBankCode,
        bankAccount,
        setBankAccount,
        getErrors: (field : string) => errorsVM.getErrors(field),
        goBackToForm() {
            setStage(WithdrawRequestStage.FILL_FORM)
        }
    }
}

export type UseWithdrawRequestForReturn = {
    stage: WithdrawRequestStage
    isLoading: boolean
    bankAccountUpdate(): Promise<void>
    withdraw(): Promise<void>
    banks: Bank[]
    manualBankCode: string
    setManualBankCode: (value: MithrilHooks.ValueOrFn<string>) => void
    bankAccount: BankAccount
    setBankAccount: (value: MithrilHooks.ValueOrFn<BankAccount>) => void
    getErrors: (field: string) => string[]
    goBackToForm(): void
}

function bankAccountWithUserDocumentAndName(bankAccount : BankAccount, user : UserDetails) : BankAccount {
    return {
        ...bankAccount,
        owner_document: user.owner_document,
        owner_name: user.name,
    }    
}