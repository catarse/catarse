/**
 * window.c.ProjectReminder component
 * A component that displays a clickable project reminder element.
 * The component can be of two types: a 'link' or a 'button'
 *
 * Example:
 *  view: {
 *      return m.component(c.ProjectReminder, {project: project, type: 'button'})
 *  }
 */
import m from 'mithril';
import prop from 'mithril/stream';
import { catarse } from '../api';
import models from '../models';
import h from '../h';
import popNotification from './pop-notification';

const projectReminder = {
    oninit: function(vnode) {
        let l = prop(false);
        const project = vnode.attrs.project,
            filterVM = catarse.filtersVM({
                project_id: 'eq'
            }),
            storeReminderName = 'reminder',
            popNotification = prop(false),
            submitReminder = () => {
                if (!h.getUser()) {
                    h.storeAction(storeReminderName, project().project_id);
                    return h.navigateToDevise(`?redirect_to=/projects/${project().project_id}`);
                }
                const loaderOpts = project().in_reminder ? models.projectReminder.deleteOptions(filterVM.parameters()) : models.projectReminder.postOptions({
                    project_id: project().project_id
                });
                l = catarse.loaderWithToken(loaderOpts);

                l.load().then(() => {
                    project().in_reminder = !project().in_reminder;

                    if (project().in_reminder) {
                        popNotification(true);
                        setTimeout(() => {
                            popNotification(false);
                            h.redraw();
                        }, 5000);
                    } else {
                        popNotification(false);
                    }
                    
                    h.redraw();
                });
            };

        if (h.callStoredAction(storeReminderName) == project().project_id) {
            submitReminder();
        }

        filterVM.project_id(project().project_id);

        vnode.state = {
            l,
            submitReminder,
            popNotification
        };
    },
    view: function({state, attrs}) {
        const mainClass = (attrs.type === 'button') ? '' : '.u-text-center.u-marginbottom-30',
            buttonClass = (attrs.type === 'button') ? 'w-button btn btn-terciary btn-no-border' : 'btn-link link-hidden fontsize-large',
            hideTextOnMobile = attrs.hideTextOnMobile || false,
            project = attrs.project,
            onclickFunc = h.analytics.event({ cat: 'project_view', act: 'project_floatingreminder_click', project: project() }, state.submitReminder);

        return m(`#project-reminder${mainClass}`, [
            m('a.btn.btn-small.btn-terciary.w-hidden-main.w-hidden-medium[data-ix=\'popshare\'][href=\'#\']', {
                onclick: onclickFunc
            },

              (project().in_reminder ? [
                  m('span.fa.fa-bookmark'),
                  ' Lembrete ativo'
              ] : [
                  m('span.fa.fa-bookmark-o'),
                  ' Lembrar-me'
              ])
            ),

            m(`button[class="w-hidden-small w-hidden-tiny ${buttonClass} ${(project().in_reminder ? 'link-hidden-success' : 'fontcolor-secondary')} fontweight-semibold"]`, {
                onclick: onclickFunc
            }, [
                (state.l() ? h.loader() : (project().in_reminder ? m('span.fa.fa-bookmark') : m('span.fa.fa-bookmark-o')))
            ]), (state.popNotification() ? m(popNotification, {
                message: 'Ok, Vamos te mandar um lembrete por e-mail antes do fim da campanha!'
            }) : '')
        ]);
    }
};

export default projectReminder;
