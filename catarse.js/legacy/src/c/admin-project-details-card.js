/**
 * window.c.AdminProjectDetailsCard component
 * render an box with some project statistics info
 *
 * Example:
 * m.component(c.AdminProjectDetailsCard, {
 *     resource: projectDetail Object,
 * })
 */
import m from 'mithril';
import _ from 'underscore';
import h from '../h';
import moment from 'moment';

const adminProjectDetailsCard = {
    oninit: function(vnode) {
        let project = vnode.attrs.resource,
            isFinalLap = () =>
                // @TODO: use 8 days because timezone on js
                 !_.isNull(project.expires_at) && moment().add(8, 'days') >= moment(project.zone_expires_at);
        vnode.state = {
            project,
            remainingTextObj: h.translatedTime(project.remaining_time),
            elapsedTextObj: h.translatedTime(project.elapsed_time),
            isFinalLap
        }
    },
    view: function({state}) {
        let project = state.project,
            progress = project.progress.toFixed(2),
            statusTextObj = h.projectStateTextClass(project.state, project.has_cancelation_request),
            remainingTextObj = state.remainingTextObj,
            elapsedTextObj = state.elapsedTextObj;

        return m('.project-details-card.card.u-radius.card-terciary.u-marginbottom-20', [
            m('div', [
                m('.fontsize-small.fontweight-semibold', [
                    m('span.fontcolor-secondary', 'Status:'), ' ',
                    m('span', {
                        class: statusTextObj.cssClass
                    }, (state.isFinalLap() && project.open_for_contributions ? 'RETA FINAL' : statusTextObj.text)), ' '
                ]), project.is_published ? [
                    m('.meter.u-margintop-20.u-marginbottom-10', [
                        m('.meter-fill', {
                            style: {
                                width: `${progress > 100 ? 100 : progress}%`
                            }
                        })
                    ]),
                    m('.w-row', [
                        m('.w-col.w-col-3.w-col-small-3.w-col-tiny-6', [
                            m('.fontcolor-secondary.lineheight-tighter.fontsize-small', 'financiado'),
                            m('.fontweight-semibold.fontsize-large.lineheight-tight', `${progress}%`)
                        ]),
                        m('.w-col.w-col-3.w-col-small-3.w-col-tiny-6', [
                            m('.fontcolor-secondary.lineheight-tighter.fontsize-small', 'levantados'),
                            m('.fontweight-semibold.fontsize-large.lineheight-tight', [
                                `R$ ${h.formatNumber(project.pledged, 2)}`,
                            ]),
                        ]),
                        m('.w-col.w-col-3.w-col-small-3.w-col-tiny-6', [
                            m('.fontcolor-secondary.lineheight-tighter.fontsize-small', 'apoios'),
                            m('.fontweight-semibold.fontsize-large.lineheight-tight', project.total_contributions)
                        ]),
                        m('.w-col.w-col-3.w-col-small-3.w-col-tiny-6', [
                            (_.isNull(project.expires_at) ? [
                                m('.fontcolor-secondary.lineheight-tighter.fontsize-small', 'iniciado há'),
                                m('.fontweight-semibold.fontsize-large.lineheight-tight', `${elapsedTextObj.total} ${elapsedTextObj.unit}`)
                            ] : [
                                m('.fontcolor-secondary.lineheight-tighter.fontsize-small', 'restam'),
                                m('.fontweight-semibold.fontsize-large.lineheight-tight', `${remainingTextObj.total} ${remainingTextObj.unit}`)
                            ])
                        ])
                    ])
                ] : ''
            ])
        ]);
    }
};

export default adminProjectDetailsCard;
