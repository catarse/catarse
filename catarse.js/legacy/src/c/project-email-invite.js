import m from 'mithril';
import prop from 'mithril/stream';
import h from '../h';
import _ from 'underscore';
import { catarse } from '../api';
import models from '../models';
import popNotification from './pop-notification';
import projectGoogleContactImport from './project-google-contact-import';

const projectEmailInvite = {
    oninit: function(vnode) {
        const emailText = prop(''),
            loading = prop(false),
            project = vnode.attrs.project,
            showSuccess = prop(false),

            submitInvite = () => {
                if (_.isEmpty(emailText()) || loading() === true) {
                } else {
                    loading(true);
                    const emailList = _.reduce(emailText().split('\n'), (memo, text) => {
                        if (h.validateEmail(text)) {
                            memo.push(text);
                        }
                        return memo;
                    }, []);

                    if (!_.isEmpty(emailList)) {
                        showSuccess(false);
                        catarse.loaderWithToken(
                              models.inviteProjectEmail.postOptions({
                                  data: {
                                      project_id: project.project_id,
                                      emails: emailList
                                  }
                              })).load().then((data) => {
                                  emailText('');
                                  loading(false);
                                  showSuccess(true);
                              });
                    } else {
                        loading(false);
                    }
                }
            };

        vnode.state = {
            emailText,
            submitInvite,
            loading,
            showSuccess
        };
    },
    view: function({state, attrs}) {
        const project = attrs.project;

        return m('.email-invite-box', [
            (state.showSuccess() ? m(popNotification, { message: 'Convites enviados.' }) : ''),
            (state.loading() ? h.loader()
             : [
                 m('.w-form', [
                     m('form', [
                         m('.u-marginbottom-10', [
                             m(projectGoogleContactImport, {
                                 project,
                                 showSuccess: state.showSuccess
                             })
                         ]),
                         m('textarea.positive.text-field.w-input[maxlength="5000"][placeholder="Adicione um ou mais emails, separados por linha."]', {
                             onchange: m.withAttr('value', state.emailText),
                             value: state.emailText()
                         })
                     ])
                 ]),
                 m('.u-text-center', [
                     m('a.btn.btn-inline.btn-medium.w-button[href="javascript:void(0)"]', {
                         onclick: state.submitInvite
                     }, 'Enviar convites')
                 ])
             ])
        ]);
    }
};

export default projectEmailInvite;
