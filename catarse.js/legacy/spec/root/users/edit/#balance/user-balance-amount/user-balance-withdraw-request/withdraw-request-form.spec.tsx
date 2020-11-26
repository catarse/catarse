import type { } from 'jasmine'
import mq from 'mithril-query'
import { WithdrawRequestForm, WithdrawRequestFormProps } from '../../../../../../../src/root/users/edit/#balance/user-balance-amount/user-balance-withdraw-request/withdraw-request-form'
import { UserDetails } from '../../../../../../../src/entities'
import { Balance, BankAccount } from '../../../../../../../src/root/users/edit/#balance/controllers/use-cases/entities'

describe('WithdrawRequestForm', () => {
    describe('view', () => {

        const props : WithdrawRequestFormProps = {
            user: {} as UserDetails,
            balance: {} as Balance,
            bankAccount: {} as BankAccount,
            onChange() {},
            manualBankCode: '',
            onChangeManualBankCode() {},
            banks: [],
            getErrors: (field : string) => [],
            async bankAccountUpdate() {},
        }

        it('should render validation error', () => {
            props.getErrors = (field : string) => field === 'validation_error' ? ['VALIDATION_ERROR_MESSAGE'] : []

            const container = mq(<WithdrawRequestForm {...props} />)

            container.should.contain('VALIDATION_ERROR_MESSAGE')
        })
    })
})