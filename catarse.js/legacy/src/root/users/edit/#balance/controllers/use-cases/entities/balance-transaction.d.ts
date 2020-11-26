export type BalanceTransaction = {
    created_at: string | null
    credit: number
    debit: number
    source: BalanceTransactionSource[]
    total_amount: number
    user_id: number
}

export type BalanceTransactionSource = {
    amount: number
    event_name: string
    origin_objects: {
        id: number
        project_id: number
        service_fee: string
        project_name: string
        to_user_name: string
        from_user_name: string
        contribution_id: number | null
        subscriber_name: string
        contributor_name: string
        subscription_reward_label: string
    }
}