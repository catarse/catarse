import m from 'mithril'
import { withHooks } from 'mithril-hooks'
import { Subscription } from '../entities'
import { I18nText } from '../shared/components/i18n-text'

export default withHooks<PaymentMethodIconProps>(PaymentMethodIcon);

export type PaymentMethodIconProps = {
    subscription: Subscription
    paymentMethodOverride?: string
}

function PaymentMethodIcon({subscription, paymentMethodOverride} : PaymentMethodIconProps) {
    const lastPaymentMethod = paymentMethodOverride || subscription?.last_payment_data?.payment_method || subscription.payment_method
    const paymentClass = { boleto: 'fa-barcode', credit_card: 'fa-credit-card' }[lastPaymentMethod]
    return (
        <span>
            <span class={`fa ${paymentClass}`}></span>
            <I18nText scope={`projects.subscription_fields.${lastPaymentMethod}`} />
        </span>
    )
}
