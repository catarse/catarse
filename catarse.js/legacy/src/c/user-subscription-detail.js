import m from 'mithril';
import _ from 'underscore';
import userSubscriptionBox from './user-subscription-box';

const userSubscriptionDetail = {
    oninit: function(vnode) {
        const subscription = vnode.attrs.subscription;

        vnode.state = {
            subscription
        };
    },
    view: function({state, attrs}) {
        const subscription = attrs.subscription;

        return m(userSubscriptionBox, { subscription });
    }
};

export default userSubscriptionDetail;
