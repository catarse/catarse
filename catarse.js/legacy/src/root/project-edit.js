import m from 'mithril';
import prop from 'mithril/stream';
import _ from 'underscore';
import h from '../h';
import projectVM from '../vms/project-vm';
// @TODO move all tabs to c/
// using the inside components that root tabs use
import projectEditGoal from '../root/project-edit-goal';
import projectEditWelcomeMessage from '../root/project-edit-welcome';
import projectEditGoals from '../root/project-edit-goals';
import projectEditBasic from '../root/project-edit-basic';
import projectEditDescription from '../root/project-edit-description';
import projectEditVideo from '../root/project-edit-video';
import projectEditBudget from '../root/project-edit-budget';
import projectEditUserAbout from '../root/project-edit-user-about';
import projectEditUserSettings from '../root/project-edit-user-settings';
import projectEditReward from '../root/project-edit-reward';
import projectEditCard from '../root/project-edit-card';
import projectEditStart from '../root/project-edit-start';
import projectPreview from '../root/project-preview';
import projectDashboardMenu from '../c/project-dashboard-menu';
import projectAnnounceExpiration from '../c/project-announce-expiration';
import projectEditTab from '../c/project-edit-tab';
import { ProjectEditIntegrations } from './project-edit-integrations';

const I18nScope = _.partial(h.i18nScope, 'projects.edit');

const projectEdit = {
    oninit: function (vnode) {
        const { project_id, user_id } = vnode.attrs;
        const project = projectVM.fetchProject(project_id);
        const c_opts = { project_id, user_id, project };
        const hash = prop(window.location.hash);

        const displayTabContent = () => {

            hash(window.location.hash);
            const isUnpublishedAdmin = !project().is_published || project().is_admin_role;
            const isEmptyHash = _.isEmpty(hash()) || hash() === '#_=_';

            switch (window.location.hash) {
                case '#video':
                    if (projectVM.isSubscription(project)) return null
                    else return m(projectEditTab, {
                        title: window.I18n.t('video_html', I18nScope()),
                        subtitle: window.I18n.t('video_subtitle', I18nScope()),
                        content: m(projectEditVideo, _.extend({}, c_opts))
                    });

                case '#description':
                    return m(projectEditTab, {
                        title: window.I18n.t('description', I18nScope()),
                        subtitle: window.I18n.t('description_subtitle', I18nScope()),
                        content: m(projectEditDescription, _.extend({}, c_opts))
                    });

                case '#budget':
                    return m(projectEditTab, {
                        title: window.I18n.t('budget', I18nScope()),
                        subtitle: window.I18n.t('budget_subtitle', I18nScope()),
                        content: m(projectEditBudget, _.extend({}, c_opts))
                    });

                case '#reward':
                    return m(projectEditTab, {
                        title: window.I18n.t('reward_html', I18nScope()),
                        subtitle: window.I18n.t('reward_subtitle', I18nScope()),
                        content: m(projectEditReward, _.extend({}, c_opts))
                    });

                case '#integrations':
                    return m(projectEditTab, {
                        title: window.I18n.t('integrations_html', I18nScope()),
                        subtitle: window.I18n.t('integrations_subtitle', I18nScope()),
                        content: m(ProjectEditIntegrations, _.extend({}, c_opts))
                    });

                case '#user_settings':
                    return m(projectEditTab, {
                        title: window.I18n.t('user_settings', I18nScope()),
                        subtitle: window.I18n.t('user_settings_subtitle', I18nScope()),
                        content: m(projectEditUserSettings, _.extend({}, c_opts))
                    });

                case '#user_about':
                    return m(projectEditTab, {
                        title: window.I18n.t('user_about', I18nScope()),
                        subtitle: window.I18n.t('user_about_subtitle', I18nScope()),
                        content: m(projectEditUserAbout, _.extend({}, c_opts))
                    });

                case '#welcome_message':
                    return m(projectEditTab, {
                        title: window.I18n.t('welcome', I18nScope()),
                        subtitle: window.I18n.t('welcome_subtitle', I18nScope()),
                        content: m(projectEditWelcomeMessage, _.extend({}, c_opts))
                    });

                case '#card':
                    return m(projectEditTab, {
                        title: window.I18n.t(`card_${project().mode}`, I18nScope()),
                        subtitle: window.I18n.t(`card_subtitle_${project().mode}`, I18nScope()),
                        content: m(projectEditCard, _.extend({}, c_opts))
                    });

                case '#goals':
                    return m(projectEditTab, {
                        title: window.I18n.t('goals', I18nScope()),
                        subtitle: '',
                        content: m(projectEditGoals, _.extend({}, c_opts))
                    });

                case '#announce_expiration':
                    return m(projectEditTab, {
                        title: window.I18n.t('announce_expiration', I18nScope()),
                        subtitle: window.I18n.t('announce_expiration_subtitle', I18nScope()),
                        content: m(projectAnnounceExpiration, _.extend({}, c_opts))
                    });

                case '#preview':
                    return m(projectPreview, _.extend({}, c_opts));

                case '#start':
                    return m(projectEditStart, _.extend({}, c_opts));

                case '#goal':
                    if (isUnpublishedAdmin)
                        return m(projectEditTab, {
                            title: window.I18n.t('goal', I18nScope()),
                            subtitle: window.I18n.t('goal_subtitle', I18nScope()),
                            content: m(projectEditGoal, _.extend({}, c_opts))
                        });

                case '#basics':
                    if (isUnpublishedAdmin)
                        return m(projectEditTab, {
                            title: window.I18n.t('basics', I18nScope()),
                            subtitle: window.I18n.t('basics_subtitle', I18nScope()),
                            content: m(projectEditBasic, _.extend({}, c_opts))
                        });

                default:
                    return m(projectEditTab, {
                        title: window.I18n.t('basics', I18nScope()),
                        subtitle: window.I18n.t('basics_subtitle', I18nScope()),
                        content: m(projectEditBasic, _.extend({}, c_opts))
                    });
            }
        };

        h.redrawHashChange();
        vnode.state = {
            displayTabContent,
            hash,
            project
        };
    },
    view: function ({ state, attrs }) {
        const project = state.project;

        return m('.project-dashboard-edit',
            (
                project() ? [
                    m(`.w-section.section-product.${project().mode}`),
                    state.displayTabContent(),
                    (
                        project() ?
                            m(projectDashboardMenu, { project })
                            :
                            ''
                    )
                ]
                    :
                    ''
            )
        );
    }
};

export default projectEdit;
