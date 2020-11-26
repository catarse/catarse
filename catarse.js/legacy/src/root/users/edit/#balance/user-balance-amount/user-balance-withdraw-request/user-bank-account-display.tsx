import { BankAccount, Balance } from '../../controllers/use-cases/entities'
import { withHooks, useEffect, useState, useMemo } from 'mithril-hooks'
import { CurrencyFormat } from '../../../../../../shared/components/currency-format'
import { I18nText } from '../../../../../../shared/components/i18n-text'

export type UserBankAccountDisplayProps = {
    bankAccount: BankAccount
    balance: Balance
}

export const UserBankAccountDisplay = withHooks<UserBankAccountDisplayProps>(_UserBankAccountDisplay)

function _UserBankAccountDisplay({ bankAccount, balance } : UserBankAccountDisplayProps) {

    const fieldsDisplay : { label : JSX.Element, value : string | JSX.Element }[] = [
        {
            label: <I18nText scope='users.balance.bank.name' />,
            value: bankAccount.owner_name,
        },
        {
            label: <I18nText scope='users.balance.bank.cpf_cnpj' />,
            value: bankAccount.owner_document,
        },
        {
            label: <I18nText scope='users.balance.bank.bank_name' />,
            value: bankAccount.bank_name,
        },
        {
            label: <I18nText scope='users.balance.bank.agency' />,
            value: `${bankAccount.agency}-${bankAccount.agency_digit}`,
        },
        {
            label: <I18nText scope='users.balance.bank.account' />,
            value: `${bankAccount.account}-${bankAccount.account_digit}`,
        },
        {
            label: <I18nText scope='users.balance.bank.account_type_name' />,
            value: <I18nText scope={`users.balance.bank.account_type.${bankAccount.account_type}`} />,
        }
    ]

    return (
        <>
            <div class='fontsize-base u-marginbottom-20'>
                <span class='fontweight-semibold'>
                    <I18nText scope='shared.value_text' />:&nbsp;
                </span>
                <span class='text-success'>
                    <CurrencyFormat label='R$' value={balance.amount} />
                </span>
            </div>
            <div class='fontsize-base u-marginbottom-10'>
                <span style='font-weight: 600;'>
                    <I18nText scope='users.balance.bank.account' />
                </span>
            </div>
            <div class='fontsize-small u-marginbottom-10'>
                {fieldsDisplay.map(field => (
                    <div>
                        <span class='fontcolor-secondary'>{field.label} </span>
                        {field.value}
                    </div>
                ))}
            </div>
        </>
    )
}