import { UserDetails } from '../../../entities'
import h from '../../../h'
import { UserDetailsAccessWrapper } from './user-details-access-wrapper'

export function getCurrentUserCached(): UserDetails {
    try {
        const userDataString = document.body.getAttribute('data-user')
        if (userDataString) {
            const userData = JSON.parse(userDataString || '') as UserDetails
            return new UserDetailsAccessWrapper(userData)
        } else {
            return new UserDetailsAccessWrapper(null)
        }
    } catch (error) {
        h.captureException(error)
        return new UserDetailsAccessWrapper(null)
    }
}
