import m from 'mithril';
import h from '../h';
import _ from 'underscore';

const I18nScope = _.partial(h.i18nScope, 'projects.insights.progress_bar');

const projectSuccessfulProgressBar = {
    oninit: function(vnode) {
        const designStates = {
                waiting_funds: {
                    processing: {
                        lineClass: '.done',
                        text: I18n.t('waiting_funds_processing_text', I18nScope()),
                        circleClass: '.current',
                        descriptionTextClass: '',
                        descriptionTextSizeClass: '.fontsize-base',
                    },
                    success: {
                        lineClass: '',
                        text: I18n.t('waiting_funds_success_text', I18nScope()),
                        circleClass: '',
                        descriptionTextClass: '.fontcolor-terciary',
                        descriptionTextSizeClass: '',
                    }
                },
                successful_waiting_transfer: {
                    processing: {
                        lineClass: '.done',
                        text: `${I18n.t('successful_waiting_transfer_processing_text', I18nScope())} ${h.momentify(vnode.attrs.project().expires_at, 'DD/MM/YYYY')}`,
                        circleClass: '.done.fa.fa-check.fa-2x',
                        descriptionTextClass: '.fontcolor-terciary',
                        descriptionTextSizeClass: '',
                    },
                    success: {
                        lineClass: '.done',
                        text: '',
                        circleClass: '.current',
                        descriptionTextClass: '',
                        descriptionTextSizeClass: '.fontsize-base',
                    }
                }
            };

        vnode.state = {
            designStates
        };
    },

    view: function({state, attrs}) {
        const 
            designComponent = state.designStates[attrs.current_state()],
            processingComponent = designComponent.processing,
            successComponent = designComponent.success;

        return m('.project-progress-bar', [
            m('.project-progress-bar-step',
                m('.project-progress-bar-content', [
                    m('.project-progress-bar-circle.done.fa.fa-check.fa-2x'),
                    m('.project-progress-bar-description.fontcolor-terciary', [
                        m('.fontsize-smaller.lineheight-tight.fontweight-semibold',
                            I18n.t('finished_initial', I18nScope())
                        ),
                        m('.fontsize-smallest',
                            `${I18n.t('finished_initial_subtitle', I18nScope())} ${h.momentify(attrs.project().expires_at,'DD/MM/YYYY')}`
                        )
                    ])
                ])
            ),
            m(`.project-progress-bar-line${processingComponent.lineClass}`),
            m('.project-progress-bar-step',
                m('.project-progress-bar-content', [
                    m(`.project-progress-bar-circle${processingComponent.circleClass}`),
                    m(`.project-progress-bar-description${processingComponent.descriptionTextClass}`, [
                        m(`.fontsize-smaller.lineheight-tight.fontweight-semibold${processingComponent.descriptionTextSizeClass}`,
                            I18n.t('finished_processing', I18nScope())
                        ),
                        m('.fontsize-smallest',
                            processingComponent.text
                        )
                    ])
                ])
            ),
            m(`.project-progress-bar-line${successComponent.lineClass}`),
            m('.project-progress-bar-step',
                m('.project-progress-bar-content', [
                    m(`.project-progress-bar-circle${successComponent.circleClass}`),
                    m(`.project-progress-bar-description${successComponent.descriptionTextClass}`, [
                        m(`.fontsize-smaller.lineheight-tight.fontweight-semibold${successComponent.descriptionTextSizeClass}`,
                            I18n.t('finished_withdraw', I18nScope())
                        ),
                        m('.fontsize-smallest',
                            successComponent.text
                        )
                    ])
                ])
            )
        ]);
    }
}

export default projectSuccessfulProgressBar;
