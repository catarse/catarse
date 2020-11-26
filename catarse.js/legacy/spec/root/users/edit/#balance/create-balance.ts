import { Balance } from '../../../../../src/root/users/edit/#balance/controllers/use-cases/entities'

export function createBalance() : Balance {
    return {
        user_id: 1,
        amount: 1000,
        last_transfer_amount: 1000,
        last_transfer_created_at: new Date().toDateString(),
        in_period_yet: false,
        has_cancelation_request: false,
    }
}