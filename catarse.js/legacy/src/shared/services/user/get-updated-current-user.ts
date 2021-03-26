import { UserDetails } from '../../../entities'
import models from '../../../models'
import { Equal, Filter, filterFactory } from '../api'
import { UserDetailsAccessWrapper } from './user-details-access-wrapper'
import { getCurrentUserCached } from './get-current-user-cached'
import { getApplicationContext } from './get-application-context'
import h from '../../../h'

interface UserDetailsApi {
    getRowWithToken(parameters: { [key:string]: string }): Promise<UserDetails[]>
}

async function getUpdatedCurrentUserFromApi(userId: number, api: UserDetailsApi, filter: Filter): Promise<UserDetails>  {
    filter.setParam('id', Equal(userId))
    try {
        const userDetails: UserDetails[] = await api.getRowWithToken(filter.toParameters())
        return new UserDetailsAccessWrapper(userDetails[0])
    } catch (loadUserFromError) {
        const context = {
            message: 'No data loaded from user',
            stack: loadUserFromError?.stack || loadUserFromError,
            context: getApplicationContext(),
        }
        h.captureMessage(JSON.stringify(context))
    }
}

export async function getUserDetailsWithUserId(userId: number): Promise<UserDetails> {
    const filter = filterFactory()
    return getUpdatedCurrentUserFromApi(userId, models.userDetail, filter)
}

export async function getUpdatedUserDetailsFromCurrentUser(): Promise<UserDetails> {
    const userId = (await getCurrentUserCached()).id
    return getUserDetailsWithUserId(userId)
}
