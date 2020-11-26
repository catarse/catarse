import m from 'mithril';
import _ from 'underscore';
import h from '../h';
import projectSuccessfulProgressBar from './project-successful-progress-bar';

const I18nScope = _.partial(h.i18nScope, 'projects.insights.processing');

const projectSuccessfulProcessing = {
    view: function ({attrs}) {
        return m('.u-marginbottom-40.w-row', [
            m('.w-col.w-col-1'),
            m('.w-col.w-col-10', [
                m('.fontweight-semibold.fontsize-larger.lineheight-looser.u-marginbottom-10.u-text-center.dashboard-header',  I18n.t('title', I18nScope())),
                m(projectSuccessfulProgressBar, { project: attrs.project, current_state: attrs.current_state }),
                m('.u-marginbottom-40.u-text-center.w-row', [
                    m('.w-col.w-col-2'),
                    m('.w-col.w-col-8', 
                        m('p.fontsize-base', [
                            m('span.fontweight-semibold', attrs.project().user.name),
                            I18n.t('text', I18nScope()),
                            m('a.alt-link.fontweight-semibold[href=\'https://suporte.catarse.me/hc/pt-br/articles/217916143\'][target=\'_blank\']', 
                                I18n.t('text_link', I18nScope())
                            )
                        ])
                    ),
                    m('.w-col.w-col-2')
                ])
            ]),
            m('.w-col.w-col-1')
        ]);
    }
};

export default projectSuccessfulProcessing;
