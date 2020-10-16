import m from 'mithril';
import _ from 'underscore';
import h from '../h';

const I18nScope = _.partial(h.i18nScope, 'projects.card');
const progressMeter = {
    oninit: function(vnode) {
        const project = vnode.attrs.project;
        const progress = vnode.attrs.progress;
        const isFinished = project => _.contains(['successful', 'failed', 'waiting_funds'], project.state);
        const cardMeter = () => {
            const failed = () => ((project.state === 'failed') || (project.state === 'waiting_funds')) ? 'card-secondary' : '';

            return `.card-project-meter.${project.mode}.${project.state}.${progress > 100 ? 'complete' : 'incomplete'}.${failed()}`;
        };
        vnode.state = {
            project,
            progress,
            cardMeter,
            isFinished
        };
    },
    view: function({state}) {
        const project = state.project;
        return m(state.cardMeter(), [
            (state.isFinished(project)) ?
            m('div',
                project.state === 'successful' && state.progress < 100 ? window.I18n.t('display_status.flex_successful', I18nScope()) : window.I18n.t(`display_status.${project.state}`, I18nScope())
            ) :
            m('.meter', [
                m('.meter-fill', {
                    style: {
                        width: `${(state.progress > 100 ? 100 : state.progress)}%`
                    }
                })
            ])
        ]);
    }
};

export default progressMeter;
