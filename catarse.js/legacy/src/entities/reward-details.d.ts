export type RewardDetails = {
    common_id: string
    deliver_at: string
    description: string
    id: number
    maximum_contributions: number | null
    minimum_value: number
    paid_count: number
    project_id: number
    row_order: number
    run_out: boolean
    shipping_options: string
    survey_finished_at: string | null
    survey_sent_at: string | null
    title: string
    updated_at: string
    uploaded_image: string | null
    waiting_payment_count: number
    welcome_message_body: string | null
    welcome_message_subject: string | null
}