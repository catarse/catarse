/*
 * UserFollowBtn - Component
 * Handles with follow / unfollow actions to an user
 *
 * Example:
 * m.component(c.UserFollowBtn, {follow_id: 10, following: false})
 */

import m from 'mithril';
import prop from 'mithril/stream';
import { catarse } from '../api';
import h from '../h';
import models from '../models';

const UserFollowBtn = {
    oninit: function(vnode) {
        const following = prop(vnode.attrs.following || false),
            followVM = catarse.filtersVM({ follow_id: 'eq' }),
            loading = prop(false),
            hover = prop(false),
            userFollowInsert = models.userFollow.postOptions({
                follow_id: vnode.attrs.follow_id,
            }),
            userFollowDelete = (() => {
                followVM.follow_id(vnode.attrs.follow_id);

                return models.userFollow.deleteOptions(followVM.parameters());
            })(),
            follow = () => {
                const l = catarse.loaderWithToken(userFollowInsert);
                loading(true);

                l.load().then(() => {
                    following(true);
                    loading(false);
                    h.redraw();
                });
            },
            unfollow = () => {
                const l = catarse.loaderWithToken(userFollowDelete);
                loading(true);

                l.load().then(() => {
                    following(false);
                    loading(false);
                    h.redraw();
                });
            };

        vnode.state = {
            following,
            follow,
            unfollow,
            loading,
            hover,
        };
    },
    view: function({ state, attrs }) {
        if (h.userSignedIn() && h.getUserID() != attrs.follow_id) {
            let disableClass = attrs.disabledClass || '.w-button.btn.btn-medium.btn-terciary.u-margintop-20',
                enabledClass = attrs.enabledClass || '.w-button.btn.btn-medium.u-margintop-20';
            if (state.loading()) {
                return h.loader();
            }
            if (state.following()) {
                return m(
                    `a${enabledClass}`,
                    {
                        onclick: state.unfollow,
                        onmouseover: () => state.hover(true),
                        onmouseout: () => state.hover(false),
                    },
                    state.hover() ? 'Deixar de seguir' : 'Seguindo'
                );
            }
            return m(`a${disableClass}`, { onclick: state.follow }, 'Seguir');
        }
        return m('');
    },
};

export default UserFollowBtn;
