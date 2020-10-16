/*
 * UserFollowCard - Component
 * User info card with follow button
 *
 * Example:
 * m.component(c.UserFollowCard, {friend: friend})
 */

import m from 'mithril';
import prop from 'mithril/stream';
import h from '../h';
import _ from 'underscore';
import UserFollowBtn from '../c/user-follow-btn';
import userVM from '../vms/user-vm';

const UserFollowCard = {
    oninit: function(vnode) {
        const friend = prop(vnode.attrs.friend);
        vnode.state = {
            friend
        };
    },
    view: function({state, attrs}) {
        const friend = state.friend(),
            profile_img = _.isEmpty(friend.avatar) ? '/assets/catarse_bootstrap/user.jpg' : friend.avatar;
        return m('.w-col.w-col-4',
          m('.card.card-backer.u-marginbottom-20.u-radius.u-text-center',
              [
                  m(`img.thumb.u-marginbottom-10.u-round[src='${profile_img}']`),
                  m('.fontsize-base.fontweight-semibold.lineheight-tight',
                m('a.link-hidden', { href: `/users/${friend.friend_id}` }, userVM.displayName(friend))
              ),
                  m('.fontcolor-secondary.fontsize-smallest.u-marginbottom-10',
                (_.isNull(friend.city) ? '' :
                         m('.fontsize-smaller.fontcolor-secondary.u-marginbottom-10', `${friend.city}, ${friend.state}`))
              ),
                  m('.fontsize-smaller',
                      [
                          m('span.fontweight-semibold', friend.total_contributed_projects),
                          ' apoiados ',
                          m.trust('&nbsp;'),
                          '| ',
                          m.trust('&nbsp;'),
                          m('span.fontweight-semibold', friend.total_published_projects),
                          ' criados'
                      ]
              ),
                  m('.btn-bottom-card.w-row',
                      [
                          m('.w-col.w-col-3.w-col-small-4.w-col-tiny-3'),
                          m('.w-col.w-col-6.w-col-small-4.w-col-tiny-6',
                    m(
                        UserFollowBtn,
                        { following: friend.following, follow_id: friend.friend_id }
                    )
                  ),
                          m('.w-col.w-col-3.w-col-small-4.w-col-tiny-3')
                      ]
              )
              ]
          )
        );
    }
};

export default UserFollowCard;
