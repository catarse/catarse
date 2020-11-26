export type Balance = {
    user_id: number		
    amount: number				
    last_transfer_amount: number
    last_transfer_created_at: string
    in_period_yet: boolean	
    has_cancelation_request: boolean
}