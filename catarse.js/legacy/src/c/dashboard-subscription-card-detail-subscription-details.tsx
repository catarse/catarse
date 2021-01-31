import m from 'mithril'
import _ from 'underscore'
import { Subscription, RewardDetails, UserDetails } from '../entities'
import h from '../h'
import SubscriptionStatusIcon from './subscription-status-icon'
import PaymentMethodIcon from './payment-method-icon'
import DashboardSubscriptionCardDetailPaymentHistory from './dashboard-subscription-card-detail-payment-history'
import { withHooks } from 'mithril-hooks'

export default withHooks<DashboardSubscriptionCardDetailSubscriptionDetailsProps>(DashboardSubscriptionCardDetailSubscriptionDetails)

type DashboardSubscriptionCardDetailSubscriptionDetailsProps = {
    subscription: Subscription
    reward: RewardDetails
    user: UserDetails
}

function DashboardSubscriptionCardDetailSubscriptionDetails(props : DashboardSubscriptionCardDetailSubscriptionDetailsProps) {
    const {
        subscription,
        reward,
        user,
    } = props

    return (
        <div class="u-marginbottom-20 card u-radius">
            <div class="fontsize-small fontweight-semibold u-marginbottom-10">
                Detalhes da assinatura
            </div>
            <div class="fontsize-smaller u-marginbottom-20">
                <div>
                    <span class="fontcolor-secondary">
                        Status:&nbsp;
                    </span>
                    <SubscriptionStatusIcon subscription={subscription}/>
                </div>
                <div>
                    <span class="fontcolor-secondary">
                        Valor do pagamento mensal:&nbsp;
                    </span>
                    R${subscription.amount / 100}
                </div>
                <div>
                    <span class="fontcolor-secondary">
                        Recompensa:&nbsp;
                    </span>
                    {!_.isEmpty(reward) ? `R$${h.formatNumber(Number(reward.minimum_value/100), 2, 3)} - ${reward.title} - ${reward.description.substring(0, 90)}(...)` : 'Sem recompensa'}
                </div>
                <div>
                    <span class="fontcolor-secondary">
                        Meio de pagamento:&nbsp;
                    </span>
                    <PaymentMethodIcon subscription={subscription} />
                </div>
                <div>
                    <span class="fontcolor-secondary">
                        Qtde. de pagamentos confirmados:&nbsp;
                    </span>
                    {subscription.paid_count} meses
                </div>
                <div class="fontsize-base u-margintop-10">
                    <span class="fontcolor-secondary">
                        Total pago:&nbsp;
                    </span>
                    <span class="fontweight-semibold text-success">
                        R${subscription.total_paid / 100}
                    </span>
                </div>
            </div>
            <div class="divider u-marginbottom-20"></div>
            <div>
                <div class="fontsize-small fontweight-semibold u-marginbottom-10">
                    Histórico de pagamentos
                </div>
                <DashboardSubscriptionCardDetailPaymentHistory
                    user={user}
                    subscription={subscription}
                />
            </div>
        </div>
    )
}
