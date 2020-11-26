import m from 'mithril';
import _ from 'underscore';
import h from '../h';
import userVM from '../vms/user-vm';
import projectVM from '../vms/project-vm';
import youtubeLightbox from '../c/youtube-lightbox';
import projectDeleteButton from '../c/project-delete-button';

const I18nScope = _.partial(h.i18nScope, 'projects.dashboard_start');
const projectEditStart = {
    view: function({attrs}) {
        return m('.dashboard-header.min-height-70.u-text-center.u-marginbottom-80', [
            m('.w-container',
                m('.u-marginbottom-40.w-row', [
                    m('.w-col.w-col-8.w-col-push-2', [
                        m('.fontsize-larger.fontweight-semibold.lineheight-looser.u-marginbottom-10',
                            window.I18n.t('title', I18nScope())
                        ),
                        m('.fontsize-small.lineheight-loose.u-marginbottom-40',
                            window.I18n.t('description', I18nScope({
                                name: attrs.project().user.name || ''
                            }))
                        ),
                        m('.card.card-terciary.u-radius',
                            m(`iframe[allowfullscreen="true"][width="630"][height="383"][frameborder="0"][scrolling="no"][mozallowfullscreen="true"][webkitallowfullscreen="true"][src=${window.I18n.t('video_src', I18nScope())}]`)
                        ),

                    ])
                ])
            ),
            (attrs.project().state === 'draft' ?
                m(projectDeleteButton, {
                    project: attrs.project()
                }) :
                '')
        ]);
    }
};

export default projectEditStart;
