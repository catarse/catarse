/**
 * window.c.userFollows component
 * Shows all user follows cards
 *
 * Example of use:
 * view: () => {
 *   ...
 *   m.component(c.userFollows, {user: user})
 *   ...
 * }
 */
import m from 'mithril';
import prop from 'mithril/stream';
import { catarse } from '../api';
import _ from 'underscore';
import h from '../h';
import models from '../models';
import UserFollowCard from '../c/user-follow-card';
import loadMoreBtn from '../c/load-more-btn';
import { getUserFollowsListVM } from '../vms/friends-vm';
const userFollows = {
    oninit: function(vnode) {
        const userFriendVM = catarse.filtersVM({ user_id: 'eq' }),
            user = vnode.attrs.user,
            hash = prop(window.location.hash),
            followsListVM = getUserFollowsListVM();
        userFriendVM.user_id(user.user_id);
        if (!followsListVM.collection().length) {
            followsListVM.firstPage(userFriendVM.parameters());
        }

        vnode.state = {
            followsListVM,
        };
    },
    view: function({ state, attrs }) {
        const followsVM = state.followsListVM;
        return m('.w-section.bg-gray.before-footer.section', [
            m('.w-container', [
                m('.w-row', [
                    _.map(followsVM.collection(), friend =>
                        m(UserFollowCard, { friend: _.extend({}, { following: true, friend_id: friend.follow_id }, friend.source) })
                    ),
                ]),
                m('.w-section.section.bg-gray', [
                    m('.w-container', [
                        m('.w-row.u-marginbottom-60', [
                            m('.w-col.w-col-5', [m('.u-marginright-20')]),
                            m(loadMoreBtn, { collection: followsVM }),
                            m('.w-col.w-col-5'),
                        ]),
                    ]),
                ]),
            ]),
        ]);
    },
};

export default userFollows;
