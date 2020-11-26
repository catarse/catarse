import m from 'mithril';
import _ from 'underscore';
import h from '../h';

const I18nScope = _.partial(h.i18nScope, 'projects.insights');

const insightsInfoBox = {
    view: function({attrs}) {
        const newCount = attrs.newCount,
            oldCount = attrs.oldCount,
            countIncrease = Math.abs(newCount - oldCount),
            arrowClass = !attrs.inverted && (newCount > oldCount) ? 'success' : 'error';

        return m('.flex-column.card.u-radius.u-marginbottom-10', [
            m('div',
              attrs.label
             ),
            m('.fontsize-smallest.fontcolor-secondary.lineheight-tighter',
              'Últimos 7 dias'
             ),
            m('.fontsize-largest.fontweight-semibold',
              attrs.info
             ),
            m(`.fontsize-small.fontweight-semibold.lineheight-tighter.text-${arrowClass}`, [
                countIncrease !== 0 ?
                    m(`span.fa.fa-arrow-${newCount > oldCount ? 'up' : 'down'}`,
                      ' '
                     ) : '',
                m(countIncrease === 0 ? 'span.fontcolor-secondary' : 'span', countIncrease)
            ]),
            m('.fontsize-mini.fontweight-semibold.fontcolor-secondary.lineheight-tighter',
              'Comparado ao período anterior'
             )
        ]);
    }
};

export default insightsInfoBox;
