import m from 'mithril';
import prop from 'mithril/stream';
import _ from 'underscore';
import moment from 'moment';
import {
    catarse
} from '../api';
import models from '../models';
import DashboardSubscriptionCardDetail from './dashboard-subscription-card-detail';
import SubscriptionStatusIcon from './subscription-status-icon';
import PaymentMethodIcon from './payment-method-icon';
import SubscriptionLastPaymentStatus from './subscription-last-payment-status';
import h from '../h';
import AnonymousBadge from './anonymous-badge';
import { RewardDetails } from '../entities/reward-details';
import { I18nText } from '../shared/components/i18n-text';

const dashboardSubscriptionCard = {
    oninit: function(vnode) {
        const subscription = vnode.attrs.subscription
        const toggleDetails = h.toggleProp(false, true)
        const user = prop(vnode.attrs.user)

        if (subscription.user_external_id) {
            const filterUserVM = catarse.filtersVM({
                    id: 'eq'
                }).id(subscription.user_external_id),
                lU = catarse.loaderWithToken(models.userDetail.getRowOptions(filterUserVM.parameters()))

            lU.load().then((data) => {
                user(_.first(data))
                h.redraw()
            }).catch(() => h.redraw())
        }

        vnode.state.toggleDetails = toggleDetails
        vnode.state.user = user
    },
    view: function({state, attrs}) {
        const subscription = attrs.subscription
        const reward = subscription.current_reward_data
        const user = state.user()
        const cardClass = state.toggleDetails() ? '.card-detailed-open' : ''

        return (
            <div class={cardClass}>
                <div onclick={state.toggleDetails.toggle} className="card card-clickable">
                    {
                        state.user() &&
                        <div className="w-row">
                            <div className="table-col w-col w-col-3">
                                <div className="w-row">
                                    <div className="w-col w-col-3">
                                        <img src={h.useAvatarOrDefault(state.user().profile_img_thumbnail)} alt="" className="u-marginbottom-10 user-avatar"/>
                                    </div>
                                    <div className="w-col w-col-9">
                                        <div className="fontsize-smaller fontweight-semibold lineheight-tighter">
                                            {state.user().name}
                                        </div>
                                        <AnonymousBadge
                                            isAnonymous={subscription.anonymous}
                                            text={
                                                <I18nText scope={'users.subscription_row.anonymous_sub_title'} />
                                            }
                                            />
                                        <div className="fontcolor-secondary fontsize-smallest">
                                            {subscription.user_email}
                                        </div>
                                    </div>
                                </div>
                            </div>
                            <div className="table-col w-col w-col-2">
                                <div className="fontsize-smaller">
                                    {_.isEmpty(reward) ? '' : `${reward.description.substring(0, 20)}...`}
                                </div>
                            </div>
                            <div className="table-col w-col w-col-1 u-text-center">
                                <div className="fontsize-smaller">
                                    R${h.formatNumber(subscription.amount / 100, 0, 3)}
                                </div>
                                <div className="fontcolor-secondary fontsize-mini fontweight-semibold lineheight-tightest">
                                    <PaymentMethodIcon subscription={subscription} />
                                </div>
                            </div>
                            <div className="w-col w-col-2 u-text-center">
                                <div className="fontsize-smaller">
                                    R${h.formatNumber(subscription.total_paid / 100, 0, 3)}
                                </div>
                                <div className="fontcolor-secondary fontsize-mini fontweight-semibold lineheight-tightest">
                                    {subscription.paid_count} meses
                                </div>
                            </div>
                            <div className="w-col w-col-2 u-text-center">
                                <SubscriptionLastPaymentStatus subscription={subscription}/>
                            </div>
                            <div className="w-col w-col-2 u-text-center">
                                <SubscriptionStatusIcon subscription={subscription}/>
                            </div>
                            <button className="w-inline-block arrow-admin fa fa-chevron-down fontcolor-secondary"></button>
                        </div>
                    }
                </div>
                {
                    state.toggleDetails() &&
                    <DashboardSubscriptionCardDetail
                        subscription={subscription}
                        reward={reward}
                        user={user}
                        />
                }
            </div>
        )
    }
};

export default dashboardSubscriptionCard;
