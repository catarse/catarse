import { UserId, UserBalanceTransfer } from './entities'

export type WithdrawFunds = (user : UserId) => Promise<UserBalanceTransfer>

export type BuildParams = {
    api: Api
    balanceTransfer: Model
}

export type Api = {
    loaderWithToken(params : UserIdParams) : {
        load(): Promise<UserBalanceTransfer>
    }
}

export type Model = {
    postOptions(params : UserIdParams) : UserIdParams
}

type UserIdParams = {
    user_id : number | string
}

export function createWithdrawRequest(params : BuildParams) : WithdrawFunds {
    const {
        api,
        balanceTransfer
    } = params

    return async (user : UserId) : Promise<UserBalanceTransfer> => {
        const loaderOptions = balanceTransfer.postOptions({ user_id: user.id })
        const requestLoader = api.loaderWithToken(loaderOptions)
        return await requestLoader.load()
    }
}