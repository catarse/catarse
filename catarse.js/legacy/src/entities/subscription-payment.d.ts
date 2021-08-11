export type SubscriptionPayment = {
    id: string,
    subscription_id: string,
    amount: 1035,
    project_id: string,
    status: string,
    paid_at: string,
    created_at: string,
    project_status: string,
    project_mode: string,
    payment_method: string,
    billing_data: {
        name: string,
        email: string,
        phone: {
            ddd: string,
            ddi: string,
            number: string
        },
        address: {
            city: string,
            state: string,
            street: string,
            country: string,
            zipcode: string,
            country_code: string,
            neighborhood: string,
            complementary: string,
            street_number: string
        },
        document_number: string
    },
    payment_method_details: {
        first_digits: string,
        last_digits: string,
        brand: string,
        country: string
    },
    gateway_id: string
}
