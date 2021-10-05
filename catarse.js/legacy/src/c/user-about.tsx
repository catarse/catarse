import m from 'mithril';
import prop from 'mithril/stream';
import _ from 'underscore';
import h from '../h';
import projectUserCard from './project-user-card';
import userVM from '../vms/user-vm';
import inlineError from './inline-error';
import { getUserDetailsWithUserId } from '../shared/services/user/get-updated-current-user';
import { UserDetails } from '../entities';

const userAbout = {
    oninit: function(vnode) {
        const userDetails = prop<UserDetails>(),
            loader = prop(true),
            error = prop(false),
            user_id = vnode.attrs.userId;

        getUserDetailsWithUserId(user_id)
            .then(userDetailsData => {
                userDetails(userDetailsData);
                loader(false);
                h.redraw();
            })
            .catch(err => {
                error(true);
                loader(false);
                h.redraw();
            });

        vnode.state = {
            userDetails,
            error,
            loader,
        };
    },
    view: function({ state }) {
        const user = state.userDetails();
        return state.error()
            ? m(inlineError, { message: 'Erro ao carregar dados.' })
            : state.loader()
            ? h.loader()
            : m(
                  ".content[id='about-tab']",
                  m(
                      ".w-container[id='about-content']",
                      m('.w-row', [
                          m('.w-col.w-col-8', m('.fontsize-base', user.about_html ? m.trust(user.about_html) : '')),
                          m('.w-col.w-col-4', user.id ? m(projectUserCard, { userDetails: prop(user), project: prop({}) }) : h.loader()),
                      ])
                  )
              );
    },
};

export default userAbout;
