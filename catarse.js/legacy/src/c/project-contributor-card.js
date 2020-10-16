import m from 'mithril';
import prop from 'mithril/stream';
import _ from 'underscore';
import h from '../h';
import UserFollowBtn from './user-follow-btn';
import userVM from '../vms/user-vm';

const projectContributorCard = {
    oninit: function(vnode) {
        const userDetails = prop({}),
            user_id = vnode.attrs.contribution.user_external_id;
        if (vnode.attrs.isSubscription) {
            userVM.fetchUser(user_id, false).then(userData => {
                userDetails(_.first(userData));
                vnode.attrs.contribution.data.profile_img_thumbnail = userDetails().profile_img_thumbnail;
                vnode.attrs.contribution.data.total_contributed_projects += userDetails().total_contributed_projects;
                vnode.attrs.contribution.data.total_published_projects += userDetails().total_published_projects;
                h.redraw();
            });
        }
        vnode.state = {
            userDetails
        };
    },
    view: function({state, attrs}) {
        const contribution = attrs.contribution;

        return m('.card.card-backer.u-marginbottom-20.u-radius.u-text-center', [
            m(`a[href="/users/${contribution.user_id}"][style="display: block;"]`, {
                onclick: h.analytics.event({
                    cat: 'project_view',
                    act: 'project_backer_link',
                    lbl: contribution.user_id,
                    project: attrs.project()
                })
            }, [
                m(`img.thumb.u-marginbottom-10.u-round[src="${!_.isEmpty(contribution.data.profile_img_thumbnail) ? contribution.data.profile_img_thumbnail : '/assets/catarse_bootstrap/user.jpg'}"]`)
            ]),
            m(`a.fontsize-base.fontweight-semibold.lineheigh-tight.link-hidden-dark[href="/users/${contribution.user_id}"]`, {
                onclick: h.analytics.event({
                    cat: 'project_view',
                    act: 'project_backer_link',
                    lbl: contribution.user_id,
                    project: attrs.project()
                })
            }, userVM.displayName(contribution.data)),
            m('.fontcolor-secondary.fontsize-smallest.u-marginbottom-10', `${h.selfOrEmpty(contribution.data.city)}, ${h.selfOrEmpty(contribution.data.state)}`),
            m('.fontsize-smaller', [
                m('span.fontweight-semibold', contribution.data.total_contributed_projects), ' apoiados  |  ',
                m('span.fontweight-semibold', contribution.data.total_published_projects), ' criado'
            ]),
            m('.btn-bottom-card.w-row', [
                m('.w-col.w-col-3.w-col-small-4.w-col-tiny-3'),
                m('.w-col.w-col-6.w-col-small-4.w-col-tiny-6', [
                    m(UserFollowBtn, {
                        follow_id: contribution.user_id,
                        following: contribution.is_follow
                    })
                ]),
                m('.w-col.w-col-3.w-col-small-4.w-col-tiny-3')
            ])
        ]);
    }
};

export default projectContributorCard;
