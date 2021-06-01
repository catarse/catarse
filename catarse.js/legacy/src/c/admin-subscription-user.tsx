import m from 'mithril';
import prop from 'mithril/stream';
import _ from 'underscore';
import h from '../h';
import adminUser from './admin-user';
import { getUserDetailsWithUserId } from '../shared/services/user/get-updated-current-user';

const adminSubscriptionUser = {
    oninit: function(vnode) {
        const user = prop({});
        getUserDetailsWithUserId(vnode.attrs.item.user_external_id).then(userDetails => user(userDetails))
        vnode.state = {
            user
        };
    },
    view: function({state, attrs}) {
        const item = attrs.item,
            customerData = item.checkout_data ? item.checkout_data.customer : {},
            customer = customerData ? customerData : {},
            user = {
                profile_img_thumbnail: state.user() ? state.user().profile_img_thumbnail : '',
                id: item.user_external_id,
                name: customer.name,
                email: item.user_email
            };

        const additionalData = m('.fontsize-smallest.fontcolor-secondary', `Gateway: ${customer.email}`);
        return state.user() ? m(adminUser, {
            item: user,
            additional_data: additionalData
        }) : h.loader();
    }
};

export default adminSubscriptionUser;
