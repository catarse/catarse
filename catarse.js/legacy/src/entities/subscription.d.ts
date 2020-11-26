export type Subscription = {
    id: string
    project_id: string
    credit_card_id: string
    paid_count: number
    total_paid: number
    status: string
    paid_at: string
    next_charge_at: string
    checkout_data: SubscriptionCheckoutData | null
    created_at: string
    user_id: string
    reward_id: string
    amount: number
    project_external_id: string
    reward_external_id: string
    user_external_id: string
    payment_method: PaymentMethod
    last_payment_id: string
    last_paid_payment_id: string
    last_paid_payment_created_at: string
    user_email: string
    search_index: string
    current_paid_subscription: SubscriptionCheckoutData | null
    current_reward_data: SubscriptionCurrentRewardData | null
    current_reward_id: string | null
    current_reward_external_id: string | null
    last_payment_data: {
        id: string
        status: string
        created_at: string
        payment_method: PaymentMethod
        refused_at: string | null
        next_retry_at: string | null
    }
    last_paid_payment_data: {
        id: string | null
        status: string | null
        created_at: string | null
        payment_method: PaymentMethod
    }
    last_payment_data_created_at: string | null
    anonymous: boolean
    project_name: string
}

export type SubscriptionCheckoutData = {
    amount: string
    card_id?: string
    customer: {
        name: string
        email: string
        phone: {
            ddd: string
            ddi: string
            number: string
        }
        address: {
            city: string
            state: string
            street: string
            country: string
            zipcode: string
            country_code: string
            neighborhood: string
            complementary: string
            street_number: string
        },
        document_number: string
    },
    anonymous: boolean
    current_ip?: string
    payment_method: PaymentMethod
    is_international: boolean
    credit_card_owner_document: string
}

type PaymentMethod = 'credit_card' | 'boleto'

type SubscriptionCurrentRewardData = {
    title: string
    row_order: number
    created_at: string
    current_ip: string
    deliver_at: string
    project_id: string
    description: string
    external_id: number
    minimum_value: string
    shipping_options: string
    welcome_message_body: string | null
    maximum_contributions: number
    welcome_message_subject: string | null
},
