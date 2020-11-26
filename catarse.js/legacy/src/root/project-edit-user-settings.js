import m from 'mithril';
import prop from 'mithril/stream';
import h from '../h';
import _ from 'underscore';
import userVM from '../vms/user-vm';
import userAboutEdit from '../c/user-about-edit';
import userSettings from '../c/user-settings';

const projectEditUserSettings = {
    oninit: function(vnode) {

        const user = prop({});

        userVM
            .fetchUser(vnode.attrs.user_id, false)
            .then((userDate) => {
                user(_.first(userDate));
                h.redraw();
            });

        vnode.state = {
            user
        };
    },

    view: function({state, attrs}) {
        return (state.user() ? m(userSettings, {
            user: state.user,
            userId: attrs.user_id,
            hideCreditCards: true,
            useFloatBtn: true,
            publishingUserSettings: true,
            isProjectUserEdit: true
        }) : m('div', h.loader()));
    }
};

export default projectEditUserSettings;
