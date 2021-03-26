import m from 'mithril';
import prop from 'mithril/stream';
import h from '../h';
import _ from 'underscore';
import userVM from '../vms/user-vm';
import userAboutEdit from '../c/user-about-edit';
import userSettings from '../c/user-settings';
import { getUserDetailsWithUserId } from '../shared/services/user/get-updated-current-user';

const projectEditUserSettings = {
    oninit: function(vnode) {

        const user = prop({});

        getUserDetailsWithUserId(vnode.attrs.user_id)
            .then((userDate) => {
                user(userDate);
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
