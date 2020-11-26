import m from 'mithril';
import prop from 'mithril/stream';
import _ from 'underscore';
import models from '../models';
import { catarse } from '../api';

const projectFriends = {
    oninit: function(vnode) {
        const project = vnode.attrs.project,
            friendsSample = prop([]),
            listVM = catarse.paginationVM(models.contributor, 'user_id.desc', {
                Prefer: 'count=exact'
            }),
            filterVM = catarse.filtersVM({
                project_id: 'eq',
                is_follow: 'eq'
            }).project_id(project.project_id).is_follow(true);

        if (!listVM.collection().length) {
            listVM.firstPage(filterVM.parameters()).then(() => {
                friendsSample(_.sample(listVM.collection(), 2));
            });
        }
        vnode.state = {
            project,
            listVM,
            friendsSample
        };
    },
    view: function({state, attrs}) {
        const project = state.project,
            friendsCount = state.listVM.collection().length,
            wrapper = attrs.wrapper || '.friend-backed-card';

        return m(wrapper, [
            m('.friend-facepile', [
                _.map(state.friendsSample(), (user) => {
                    const profile_img = _.isEmpty(user.data.profile_img_thumbnail) ? '/assets/catarse_bootstrap/user.jpg' : user.data.profile_img_thumbnail;
                    return m(`img.user-avatar[src='${profile_img}']`);
                })
            ]),
            m('p.fontsize-smallest.friend-namepile.lineheight-tighter', [
                m('span.fontweight-semibold',
                    _.map(state.friendsSample(), user => user.data.name.split(' ')[0]).join(friendsCount > 2 ? ', ' : ' e ')
                ),
                (friendsCount > 2 ? [
                    ' e ',
                    m('span.fontweight-semibold',
                        `mais ${friendsCount - state.friendsSample().length}`
                    )
                ] : ''),
                (friendsCount > 1 ?
                    ' apoiaram' : ' apoiou')
            ])
        ]);
    }
};

export default projectFriends;
