import mq from 'mithril-query'
import { UserOwnerBoxProps, UserOwnerBox } from '../../../../../../../src/root/users/edit/#balance/user-balance-amount/user-balance-withdraw-request/user-owner-box'
import type {} from 'jasmine'

describe('UserOwnerBox', () => {
    describe('view', () => {
        it('should display user data', () => {
            // 1. Arrange
            const props : UserOwnerBoxProps = {
                getErrors: (field : string) => [],
                hideAvatar: true,
                user: {
                    id: 1,
                    name: 'User Name',
                    owner_document: '123.456.789-10',
                }
            }
            // 2. Act?
            const component = mq(<UserOwnerBox {...props} />)
            // 3. Assert
            component.should.contain(props.user.name)
            component.should.contain(props.user.owner_document)
        })

        it('should display error messages', () => {
            // 1. Arrange
            const ownerNameError = 'OWNER NAME ERROR'
            const ownerDocumentError = 'OWNER DOCUMENT ERROR'
            const props : UserOwnerBoxProps = {
                getErrors: (field : string) => {
                    if (field === 'user_name') {
                        return ['_']
                    } else if (field === 'owner_name') {
                        return [ownerNameError]
                    } else if (field === 'owner_document') {
                        return [ownerDocumentError]
                    } else {
                        return []
                    }
                },
                hideAvatar: true,
                user: {
                    id: 1,
                    name: 'User Name',
                    owner_document: '123.456.789-10',
                }
            }          
            // 2. Act?
            const component = mq(<UserOwnerBox {...props} />)
            // 3. Assert
            component.should.contain(ownerNameError)
            component.should.contain(ownerDocumentError)
            component.should.have('[data-component-name="_BlockError"]')
        })
    })
})