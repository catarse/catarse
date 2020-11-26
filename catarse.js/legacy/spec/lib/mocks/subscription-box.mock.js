beforeAll(function() {

    SubscriptionBoxData = function() {
        const data = [
            // CREDIT CARD NEW PAYMENT REFUSED
            {
                status: 'started',
                last_payment_data: {
                    status: 'refused'
                },
                payment_method: 'credit_card'
            },
            // SLIP NEW PAYMENT EXPIRED
            {
                status: 'started',
                payment_status: 'pending',
                boleto_url: 'https://pagar.me',
                boleto_expiration_date: moment().subtract(2, 'days').endOf('day').format(),
                last_payment_data: {
                    status: 'paid'
                },
                payment_method: 'boleto'
            },
            // SLIP NEW PAYMENT NOT EXPIRED
            {
                status: 'started',
                payment_status: 'pending',
                boleto_url: 'https://pagar.me',
                boleto_expiration_date: moment().endOf('day').format(),
                last_payment_data: {
                    status: 'paid'
                },
                payment_method: 'boleto'
            },
            // CREDIT CARD NEW PAYMENT WAITING CONFIRM
            {
                status: 'started',
                payment_status: 'pending',
                payment_method: 'credit_card',
                last_payment_data: {
                    status: 'paid'
                }
            },
            // SLIP PAYMENT INACTIVE PENDING PAYMENT 
            {
                status: 'inactive',
                payment_status: 'pending',
                payment_method: 'boleto',
                boleto_url: 'https://pagar.me',
                boleto_expiration_date: moment().endOf('day').format(),
                last_payment_data: {
                    status: 'paid'
                }
            },
            // SUBSCRIPTION INACTIVE BY MISSING PAYMENT
            {
                status: 'inactive',
                payment_status: 'refused',
                payment_method: 'boleto',
                last_payment_data: {
                    status: 'paid'
                }
            },
            // USER CANCELED IT'S OWN SUBSCRIPTION
            {
                status: 'canceled',
                project: {
                    state: 'online'
                },  
                payment_status: 'refused',
                payment_method: 'boleto',
                last_payment_data: {
                    status: 'paid'
                }
            },
            // USER CLICKED TO CANCEL IT'S OWN SUBSCRIPTION
            {
                status: 'canceling',
                next_charge_at: moment().add(1, 'days').format()
            },
            // ACTIVE SUBSCRIPTION LAST PAYMENT REFUSED
            {
                status: 'active',
                last_payment_data: {
                    status: 'refused'
                }
            },
            // ACTIVE SUBSCRIPTION LAST PAYMENT STATUS != REFUSED AND PAYMENT STATUS PENDING
            {
                status: 'active',
                payment_status: 'paid',
                last_payment_data: {
                    status: 'paid'
                }
            },
            // ACTIVE SUBSCRIPTION BUT PENDING PAYMENT FROM EXPIRED SLIP
            {
                status: 'active',
                payment_status: 'pending',
                boleto_url: 'https://pagar.me',
                boleto_expiration_date: moment().subtract(2, 'days').endOf('day').format(),
                last_payment_data: {
                    status: 'paid'
                }
            },
            // ACTIVE SUBSCRIPTION BUT PENDING PAYMENT FROM not EXPIRED SLIP
            {
                status: 'active',
                payment_status: 'pending',
                boleto_url: 'https://pagar.me',
                boleto_expiration_date: moment().endOf('day').format(),
                last_payment_data: {
                    status: 'paid'
                }
            },
        ]
    
        return data;
    };

})