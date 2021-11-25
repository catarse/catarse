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
            user_id = vnode.attrs.userId,
            privateAboutMessage = 'Este é um perfil privado. Suas informações públicas serão exibidas somente quando tiver ao menos 1 projeto publicado no Catarse.';

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

        let builder = { requestOptions: {
            url: (`/users/${user_id}/verify_has_ongoing_or_successful_projects`),
            method: 'GET'}
        };

        const load = () => m.request(_.extend({}, {}, builder.requestOptions)),
            displayAbout = h.RedrawStream('');

        builder.requestOptions.config = (xhr) => {
            if (h.authenticityToken()) {
                xhr.setRequestHeader('X-CSRF-Token', h.authenticityToken());
            }
        };

        const requestSuccess = (res) => {
            displayAbout(res.has_ongoing_or_successful_projects);
        };

        const requestError = (e) => {
            displayAbout(false);
        };

        load().then(requestSuccess, requestError);
    
        vnode.state = {
            userDetails,
            error,
            loader,
            displayAbout,
            privateAboutMessage,
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
                          m('.w-col.w-col-8', 
                            m('.fontsize-base', 
                                state.displayAbout() ? (user.about_html ? m.trust(user.about_html) : '') : state.privateAboutMessage
                            )
                          ),
                          m('.w-col.w-col-4', user.id ? m(projectUserCard, { userDetails: prop(user), project: prop({}) }) : h.loader()),
                      ])
                  )
              );
    },
};

export default userAbout;
