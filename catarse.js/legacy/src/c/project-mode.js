/**
 * window.c.ProjectMode component
 * A simple component that displays a badge with the current project mode
 * together with a description of the mode, shown inside a tooltip.
 * It receives a project as resource
 *
 * Example:
 *  view: {
 *      return m.component(c.ProjectMode, {project: project})
 *  }
 */

import m from 'mithril';
import _ from 'underscore';
import h from '../h';
import tooltip from './tooltip';

const projectMode = {
    view: function({attrs}) {
        const project = attrs.project(),
            mode = project.mode,
            modeImgSrc = (mode === 'aon')
                ? '/assets/aon-badge.png'
                : (mode === 'sub')
                    ? '/assets/catarse_bootstrap/badge-sub-h.png'
                    : '/assets/flex-badge.png',
            modeTitle = (mode === 'aon') ? 'Campanha Tudo-ou-nada ' : 'Campanha Flexível ',
            goal = _.isNull(project.goal) ? 'não definida' : h.formatNumber(project.goal),
            buildTooltip = el => m(tooltip, {
                el,
                text: (mode === 'aon') ? `Somente receberá os recursos se atingir ou ultrapassar a meta até o dia ${h.momentify(project.zone_expires_at, 'DD/MM/YYYY')}.` : 'O realizador receberá todos os recursos quando encerrar a campanha, mesmo que não tenha atingido esta meta.',
                width: 280
            });

        return mode === 'sub' ? m(`#${mode}`, [
            !_.isEmpty(project) ? m(`img.u-marginbottom-10[src="${modeImgSrc}"][width='130']`) : '',
            m('.fontsize-smallest.lineheight-tighter', 'Assine esse projeto mensalmente.')
        ]) : m(`#${mode}.w-row`, [
            m('.w-col.w-col-2.w-col-small-2.w-col-tiny-2', [
                !_.isEmpty(project) ? m(`img[src="${modeImgSrc}"][width='30']`) : ''
            ]),
            m('.w-col.w-col-10.w-col-small-10.w-col-tiny-10', [
                m('.fontsize-base.fontweight-semibold', `Meta R$ ${h.selfOrEmpty(goal, '--')}`),
                m('.w-inline-block.fontsize-smallest', [
                    !_.isEmpty(project) ? modeTitle : '',
                    buildTooltip('span.w-inline-block.tooltip-wrapper.fa.fa-question-circle.fontcolor-secondary')
                ])
            ])
        ]);
    }
};

export default projectMode;
