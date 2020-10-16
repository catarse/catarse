import m from 'mithril';
import prop from 'mithril/stream';
import _ from 'underscore';
import moment from 'moment';
import {
    catarse
} from '../api';
import models from '../models';
import dashboardSubscriptionCardDetail from './dashboard-subscription-card-detail';
import subscriptionStatusIcon from './subscription-status-icon';
import paymentMethodIcon from './payment-method-icon';
import subscriptionLastPaymentStatus from './subscription-last-payment-status';
import h from '../h';
import anonymousBadge from './anonymous-badge';

const subscriptionScope = _.partial(h.i18nScope, 'users.subscription_row');

const dashboardSubscriptionCard = {
    oninit: function(vnode) {
        const subscription = vnode.attrs.subscription,
            reward = prop(),
            toggleDetails = h.toggleProp(false, true),
            user = prop(vnode.attrs.user);

        if (subscription.user_external_id) {
            const filterUserVM = catarse.filtersVM({
                    id: 'eq'
                }).id(subscription.user_external_id),
                lU = catarse.loaderWithToken(models.userDetail.getRowOptions(filterUserVM.parameters()));

            lU.load().then((data) => {
                user(_.first(data));
                h.redraw();
            }).catch(() => h.redraw());
        }

        const reward_id_to_search = subscription.current_reward_external_id ? subscription.current_reward_external_id : subscription.reward_external_id;

        if (reward_id_to_search) {
            const filterRewVM = catarse.filtersVM({
                    id: 'eq'
                }).id(reward_id_to_search),
                lRew = catarse.loaderWithToken(models.rewardDetail.getRowOptions(filterRewVM.parameters()));

            lRew.load().then((data) => {
                reward(_.first(data));
                h.redraw();
            }).catch(() => h.redraw());
        }
        vnode.state = {
            toggleDetails,
            reward,
            user
        };
    },
    view: function({state, attrs}) {
        const subscription = attrs.subscription,
            user = state.user(),
            cardClass = state.toggleDetails() ? '.card-detailed-open' : '';
            
        return m(`div${cardClass}`, [m('.card.card-clickable', {
            onclick: state.toggleDetails.toggle
        }, state.user() ?
                m('.w-row', [
                    m('.table-col.w-col.w-col-3',
                        m('.w-row', [
                            m('.w-col.w-col-3',
                                m(`img.u-marginbottom-10.user-avatar[src='${h.useAvatarOrDefault(state.user().profile_img_thumbnail)}']`)
                            ),
                            m('.w-col.w-col-9', [
                                m('.fontsize-smaller.fontweight-semibold.lineheight-tighter',
                                    state.user().name
                                ),
                                m(anonymousBadge, {
                                    isAnonymous: subscription.anonymous,
                                    text: ` ${window.I18n.t('anonymous_sub_title', subscriptionScope())}`
                                }),
                                m('.fontcolor-secondary.fontsize-smallest',
                                    subscription.user_email
                                )
                            ])
                        ])
                    ),
                    m('.table-col.w-col.w-col-2',
                        m('.fontsize-smaller',
                            _.isEmpty(state.reward()) ? '' : `${state.reward().description.substring(0, 20)}...`
                        )
                    ),
                    m('.table-col.w-col.w-col-1.u-text-center', [
                        m('.fontsize-smaller',
                            `R$${h.formatNumber(subscription.amount / 100, 0, 3)}`
                        ),
                        m('.fontcolor-secondary.fontsize-mini.fontweight-semibold.lineheight-tightest', [
                            m(paymentMethodIcon, {
                                subscription
                            })
                        ])
                    ]),
                    m('.w-col.w-col-2.u-text-center', [
                        m('.fontsize-smaller',
                            `R$${h.formatNumber(subscription.total_paid / 100, 0, 3)}`
                        ),
                        m('.fontcolor-secondary.fontsize-mini.fontweight-semibold.lineheight-tightest',
                            `${subscription.paid_count} meses`
                        )
                    ]),
                    m('.w-col.w-col-2.u-text-center',
                        m(subscriptionLastPaymentStatus, { subscription })
                    ),
                    m('.w-col.w-col-2.u-text-center',
                        m(subscriptionStatusIcon, {
                            subscription
                        })
                    ),
                    m('button.w-inline-block.arrow-admin.fa.fa-chevron-down.fontcolor-secondary')
                ]) : ''
            ),
            state.toggleDetails() ? m(dashboardSubscriptionCardDetail, {
                subscription,
                reward: state.reward(),
                user
            }) : ''
        ]);
    }
};

export default dashboardSubscriptionCard;
