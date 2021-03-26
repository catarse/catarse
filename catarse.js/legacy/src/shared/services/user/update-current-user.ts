import { UserDetails } from '../../../entities'
import { HttpPutRequest, httpPutRequest } from '../infra'
import { HttpHeaders } from '../infra/entities'
import { getCurrentUserCached } from './get-current-user-cached'

async function updateCurrentUserDirectRequest(userId: number, updatedUserDetail: Partial<UserDetails>, putRequest: HttpPutRequest): Promise<void> {
    const url = `/users/${userId}.json`
    const headers : HttpHeaders = { 'Content-Type': 'application/json' }
    await putRequest(url, headers, { user : updatedUserDetail }, 'json')
}

export async function updateCurrentUser(updatedUserDetails: Partial<UserDetails>) {
    const userId = (await getCurrentUserCached()).id
    await updateCurrentUserDirectRequest(userId, updatedUserDetails, httpPutRequest)
}
