import { updateUserBankAccount } from '../../../../../../../src/root/users/edit/#balance/controllers/use-cases'
import { createBankAccount } from '../../create-bank-account'
describe('UpdateUserBankAccount', () => {
    it('should update user bank account', async () => {
        // 1. Arrange
        const user : UserId = {
            id: 1
        }
        const bankAccount = createBankAccount()

        const loadUrl = `/users/${user.id}.json`

        jasmine.Ajax.stubRequest(loadUrl).andReturn({
            responseText: JSON.stringify({ success: 'OK' })
        })

        // 2. Act
        await updateUserBankAccount(user, bankAccount)

        // 3. Assert
        expect(jasmine.Ajax.requests.mostRecent().status).toEqual(200)
        expect(jasmine.Ajax.requests.mostRecent().response).toEqual(JSON.stringify({ success : 'OK' }))
    })
})