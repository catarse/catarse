import { HTMLInputEvent } from '../../../../../../entities'
import { Bank, BankAccount } from '../../controllers/use-cases/entities'
import { UserBankSearchList } from './user-bank-search-list'
import { UserBankAccountInputTextField } from './user-bank-account-input-text-field'
import { withHooks, useState, useMemo } from 'mithril-hooks'
import { UserBankAccountSelectValue } from './user-bank-account-select-value'

export type UserBankFormProps = {
    bankAccount: BankAccount
    onChange(bankAccount : BankAccount): void
    manualBankCode: string
    onChangeManualBankCode(bankCode : string): void
    banks: Bank[]
    getErrors(field : string): string[]
}

type Option = {
    label: string
    value: string
}

export const UserBankForm = withHooks<UserBankFormProps>(_UserBankForm)

function _UserBankForm(props : UserBankFormProps) {

    const [ showOtherBanks, setShowOtherBanks ] = useState(false)
    const {
        getErrors,
        banks,
        bankAccount,
        onChange,
        manualBankCode,
        onChangeManualBankCode,
    } = props
    
    const popularBanksOptions : Option[] = popularBanks.map(popBank => (
        {
            label: `${popBank.code} . ${popBank.name}`,
            value: `${popBank.id}`
        }
    ))
    
    const preFilledBankAccountNotIsPopularOnes = !popularBanks.find(popBank => popBank.id === bankAccount.bank_id)
    const shouldDisplayUserBankAccountAsOption = preFilledBankAccountNotIsPopularOnes && bankAccount.bank_code && bankAccount.bank_name && bankAccount.bank_id
    const nonPopularBankPreFilled : Option[] = shouldDisplayUserBankAccountAsOption && [
        {
            label: `${bankAccount.bank_code} . ${bankAccount.bank_name}`,
            value: `${bankAccount.bank_id}`
        }
    ]
    const bankOptions : Option[] = [
        {
            label: 'Selecione um banco',
            value: '',
        },
        ...popularBanksOptions,
        ...(nonPopularBankPreFilled || []),
        {
            label: 'Outro',
            value: '0'
        }
    ]
        
    const getHandleFor = (field : string) => ({
        errors: getErrors(field),
        value: getValueFor(field),
        onChange: handleOnChangeValueFor(field),
    })
    const getNumberValueHandleFor = (field : string) => ({
        errors: getErrors(field),
        value: getValueFor(field),
        onChange: value => handleOnChangeValueFor(field)(Number(value)),
    })
    const getValueFor = (field : string) => bankAccount[field]
    const handleOnChangeValueFor = (field : string) => (value : string | number) => onChange({...bankAccount, [field]: value } as BankAccount)

    const shouldShowOtherBanksInput = `${bankAccount.bank_id}` === '0'

    return (
        <div>
            <div class='w-row'>
                <UserBankAccountSelectValue 
                    id='bank_select'
                    className={`w-col w-col-5 w-sub-col ${shouldShowOtherBanksInput ? 'w-hidden' : ''} `}
                    labelText='Banco'
                    options={bankOptions}
                    {...getNumberValueHandleFor('bank_id')}
                    onChange={(bank_id) => {
                        const bankIdNumber = Number(bank_id)
                        if (bankIdNumber) {
                            const bank = banks.find(bank => bank.id === bankIdNumber) || popularBanks.find(bank => bank.id === bankIdNumber)
                            onChange({...bankAccount, bank_id: bank.id, bank_code: bank.code, bank_name: bank.name } as BankAccount)
                        } else {
                            handleOnChangeValueFor('bank_id')(bankIdNumber)
                        }
                    }}
                    />
                {
                    shouldShowOtherBanksInput &&
                    <div class='w-col w-col-5 w-sub-col'>
                        <div id='bank_search' class='w-row u-marginbottom-20'>
                            <div class='w-col w-col-12'>
                                <div class='input string optional user_bank_account_input_bank_number'>
                                    <label class='field-label fontsize-smaller'>
                                        Número do banco (3 números)
                                    </label>
                                    <input 
                                        type='text'
                                        id='user_bank_account_attributes_input_bank_number'
                                        maxlength='3'
                                        size='3'
                                        name='user[bank_account_attributes][input_bank_number]'
                                        value={manualBankCode}
                                        onchange={(event : HTMLInputEvent) => {
                                            const bankCode = event.target.value
                                            onChangeManualBankCode(bankCode)
                                            
                                            const bank = banks.find(bank => bank.code === bankCode)
                                            if (bank) {
                                                onChange({...bankAccount, bank_id: bank.id, bank_code: bank.code, bank_name: bank.name } as BankAccount)
                                            }
                                        }}
                                        class='string optional w-input text-field bank_account_input_bank_number'/>
                                </div>
                                <a onclick={() => setShowOtherBanks(!showOtherBanks)} class='w-hidden-small w-hidden-tiny alt-link fontsize-smaller' href='javascript:void(0);' id='show_bank_list'>
                                    Busca por nome  &gt;
                                </a>
                            </div>
                        </div>
                    </div>
                }
                {
                    showOtherBanks &&
                    <UserBankSearchList
                        banks={banks}
                        onSelect={(bank) => {
                            if (bank) {
                                onChange({...bankAccount, bank_id: bank.id, bank_code: bank.code, bank_name: bank.name })
                                setShowOtherBanks(false)
                                onChangeManualBankCode(bank.code)
                            }
                        }}
                    />
                }
                <div class='w-col w-col-7'>
                    <div class='w-row'>
                        <UserBankAccountInputTextField 
                            id='user_bank_account_attributes_agency'
                            className='w-col w-col-7 w-col-small-7 w-col-tiny-7 w-sub-col-middle'
                            labelText='Agência'
                            {...getHandleFor('agency')}
                            />
        
                        <UserBankAccountInputTextField
                            id='user_bank_account_attributes_agency_digit'
                            className='w-col w-col-5 w-col-small-5 w-col-tiny-5'
                            labelText='Dígito agência'
                            required={false}
                            {...getHandleFor('agency_digit')}
                            />
                    </div>
                </div>
            </div>
            <div class='w-row'>
                <UserBankAccountSelectValue
                    id='account_type_select'
                    className='w-col w-col-5 w-sub-col'
                    labelText='Tipo de conta'
                    options={accountTypeOptions}
                    {...getHandleFor('account_type')}
                    />
                <div class='w-col w-col-7'>
                    <div class='w-row'>
                        <UserBankAccountInputTextField
                            id='user_bank_account_attributes_account'
                            className='w-col w-col-7 w-col-small-7 w-col-tiny-7 w-sub-col-middle'
                            labelText='No. da conta'
                            {...getHandleFor('account')}
                        />
                        <UserBankAccountInputTextField
                            id='user_bank_account_attributes_account_digit'
                            className='w-col w-col-5 w-col-small-5 w-col-tiny-5'
                            labelText='Dígito conta'
                            {...getHandleFor('account_digit')}
                        />
                    </div>
                </div>
            </div>
        </div>
    )
}

const popularBanks : Bank[] = [
    {
        id: 51,
        code: '001',
        name: 'Banco do Brasil S.A.'
    }, 
    {
        id: 131,
        code: '341',
        name: 'Itaú Unibanco S.A.'
    }, 
    {
        id: 122,
        code: '104',
        name: 'Caixa Econômica Federal'
    }, 
    {
        id: 104,
        code: '033',
        name: 'Banco Santander  (Brasil)  S.A.'
    }, 
    {
        id: 127,
        code: '399',
        name: 'HSBC Bank Brasil S.A. - Banco Múltiplo'
    }, 
    {
        id: 23,
        code: '237',
        name: 'Banco Bradesco S.A.'
    }
]

const accountTypeOptions : { label : string, value : string }[] = [
    {
        label: 'Conta corrente',
        value: 'conta_corrente',
    },
    {
        label: 'Conta poupança',
        value: 'conta_poupanca',
    },
    {
        label: 'Conta corrente conjunta',
        value: 'conta_corrente_conjunta',
    },
    {
        label: 'Conta poupança conjunta',
        value: 'conta_poupanca_conjunta',
    },
]