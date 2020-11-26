import m from 'mithril'
import { Subscription } from '../entities'
import { I18nText } from '../shared/components/i18n-text'

export default {
    view: ({attrs}) => PaymentMethodIcon(attrs)
}

export type PaymentMethodIconProps = {
    subscription: Subscription
}

function PaymentMethodIcon({subscription} : PaymentMethodIconProps) {
    const lastPaymentMethod = subscription?.last_payment_data?.payment_method || subscription.payment_method
    const paymentClass = { boleto: 'fa-barcode', credit_card: 'fa-credit-card' }[lastPaymentMethod]
    return (
        <span>
            <span class={`fa ${paymentClass}`}></span>
            <I18nText scope={`projects.subscription_fields.${lastPaymentMethod}`} />
        </span>
    )
}
