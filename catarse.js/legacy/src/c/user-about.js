import m from 'mithril';
import prop from 'mithril/stream';
import _ from 'underscore';
import h from '../h';
import userCard from '../c/user-card';
import userVM from '../vms/user-vm';
import inlineError from './inline-error';

const userAbout = {
    oninit: function(vnode) {
        const userDetails = prop({}),
            loader = prop(true),
            error = prop(false),
            user_id = vnode.attrs.userId;

        userVM
            .fetchUser(user_id, false)
            .then(userDetailsData => {
                userDetails(_.first(userDetailsData));
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
                          m('.w-col.w-col-4', user.id ? m(userCard, { userId: user.id }) : h.loader()),
                      ])
                  )
              );
    },
};

export default userAbout;
