import m from 'mithril';
import _ from 'underscore';
import h from '../h';
import models from '../models';
import dashboardSubscriptionCardDetailSubscriptionDetails from './dashboard-subscription-card-detail-subscription-details';
import dashboardSubscriptionCardDetailUserProfile from './dashboard-subscription-card-detail-user-profile';
import dashboardSubscriptionCardDetailUserAddress from './dashboard-subscription-card-detail-user-address';

const dashboardSubscriptionCardDetail = {
    oninit: function(vnode) {
        const userDetailsOptions = {
            id: vnode.attrs.user.common_id
        };

        const userDetailsLoader = models.commonUserDetails.getRowWithToken(userDetailsOptions);

        userDetailsLoader.then((user_details) => {
            vnode.attrs.user.address = user_details.address;
            h.redraw();
        });

        vnode.state = {
            displayModal: h.toggleProp(false, true)
        };
    },

    view: function({state, attrs}) {
        const subscription = attrs.subscription,
            user = _.extend({ project_id: subscription.project_external_id }, attrs.user),
            reward = attrs.reward,
            displayModal = state.displayModal;

        return m('.details-backed-project.card',
            m('.card.card-terciary',
                m('.w-row', [
                    m('.w-col.w-col-7', [
                        m(dashboardSubscriptionCardDetailSubscriptionDetails, { user, subscription, reward })
                    ]),
                    m('.w-col.w-col-5', [
                        m(dashboardSubscriptionCardDetailUserProfile, { user, subscription, displayModal }),
                        m(dashboardSubscriptionCardDetailUserAddress, { user })
                    ])
                ])
            )
        );
    }
};

export default dashboardSubscriptionCardDetail;
