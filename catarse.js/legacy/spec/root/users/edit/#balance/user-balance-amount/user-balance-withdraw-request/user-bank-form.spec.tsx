import mq from 'mithril-query'
import { BankAccount, Bank } from '../../../../../../../src/root/users/edit/#balance/controllers/use-cases/entities'
import { waitFor } from '../../../../../../lib/wait-for'
import { UserBankFormProps, UserBankForm } from '../../../../../../../src/root/users/edit/#balance/user-balance-amount/user-balance-withdraw-request/user-bank-form'

describe('UserBankForm', () => {

    describe('view', () => {
        const bankAccount : BankAccount = {
            bank_account_id: 1,
            account: '123923',
            account_digit: '0',
            agency: '1234',
            agency_digit: '1',
            bank_id: 1000,
            account_type: 'conta_corrent',
            bank_code: '104',
            bank_name: 'CEF',
            created_at: null,
            owner_document: '12345678910',
            owner_name: 'Bank Account User Name',
            updated_at: null,
            user_id: 1,
        }

        const props : UserBankFormProps = {
            bankAccount,
            onChange(bankAccount : BankAccount) {
                
            },
            manualBankCode: '',
            onChangeManualBankCode(bankCode : string) {

            },
            banks: [],
            getErrors(field : string) {
                return []
            }
        }

        it('should allow user to change account number', () => {

            // 1. arrange
            const newAccount = '12345'
            const localProps = { ...props }
            spyOn(localProps, 'onChange')

            const component = mq(<UserBankForm {...localProps} />)

            // 2. act
            component.setValue('#user_bank_account_attributes_account > input', newAccount)
            
            // 3. assert
            expect(localProps.onChange).toHaveBeenCalledWith({ ...bankAccount, account: newAccount } as BankAccount)
        })

        it('should allow user to change account digit', () => {

            // 1. arrange
            const newAccountDigit = '4'
            const localProps = { ...props }
            spyOn(localProps, 'onChange')

            const component = mq(<UserBankForm {...localProps} />)

            // 2. act
            component.setValue('#user_bank_account_attributes_account_digit > input', newAccountDigit)

            // 3. assert
            expect(localProps.onChange).toHaveBeenCalledWith({ ...bankAccount, account_digit: newAccountDigit } as BankAccount)
        })
        
        it('should allow user to change agency number', () => {

            // 1. arrange
            const newAgency = '1234'
            const localProps = { ...props }
            spyOn(localProps, 'onChange')

            const component = mq(<UserBankForm {...localProps} />)

            // 2. act
            component.setValue('#user_bank_account_attributes_agency > input', newAgency)

            // 3. assert
            expect(localProps.onChange).toHaveBeenCalledWith({ ...bankAccount, agency: newAgency } as BankAccount)            
        })
        
        it('should allow user to change agency digit', () => {

            // 1. arrange
            const newAgencyDigit = '9'            
            const localProps = { ...props }
            spyOn(localProps, 'onChange')

            const component = mq(<UserBankForm {...localProps} />)

            // 2. act
            component.setValue('#user_bank_account_attributes_agency_digit > input', newAgencyDigit)

            // 3. assert
            expect(localProps.onChange).toHaveBeenCalledWith({ ...bankAccount, agency_digit: newAgencyDigit } as BankAccount)
        })

        it('should allow user to change bank from one of the popular list', async () => {
            
            // 1. arrange
            const bank : Bank = {
                id: 51,
                code: '001',
                name: 'Banco do Brasil S.A.'
            }
            const localProps = { ...props }
            spyOn(localProps, 'onChange')

            const component = mq(<UserBankForm {...localProps} />)

            // 2. act
            component.setValue('#bank_select select.bank-select', 51)

            // 3. assert
            expect(localProps.onChange).toHaveBeenCalledWith({ ...bankAccount, bank_code: bank.code, bank_id: bank.id, bank_name: bank.name } as BankAccount)
        })

        it('should allow user to change bank code typing it', async () => {
            
            // 1. arrange
            const bank : Bank = {
                id: 999,
                code: '999',
                name: 'BANK NAME S.A.'
            }
            const localProps : UserBankFormProps = { ...props, banks: [bank] }
            spyOn(localProps, 'onChange')

            const component = mq(<UserBankForm {...localProps} />)

            // 2. act
            component.setValue('#bank_select select.bank-select', 999)

            // 3. assert
            expect(localProps.onChange).toHaveBeenCalledWith({ ...bankAccount, bank_code: bank.code, bank_id: bank.id, bank_name: bank.name } as BankAccount)
        })
    })
})
