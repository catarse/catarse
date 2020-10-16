/**
 * window.c.ProjectDataTable component
 * A table interface constructor that should be used on project related dashboards.
 * It takes an array and a lable as it's sources.
 * The first item in the array is the header descriptor and the rest of them are row data.
 * Rows may return a string or an array and this value will be used as a row output.
 * All table rows are sortable by default. If you want to use a custom value as sort parameter
 * you may set a 2D array as row. In this case, the first array value will be the custom value
 * while the other will be the actual output.
 * Example:
 * m.component(c.ProjectDataTable, {
 *      label: 'Table label',
 *      table: [
 *          ['col header 1', 'col header 2'],
 *          ['value 1x1', [3, 'value 1x2']],
 *          ['value 2x1', [1, 'value 2x2']] //We are using a custom comparator two col 2 values
 *      ],
 *      //Allows you to set a specific column to be ordered by default.
 *      //If no value is set, the first row will be the default one to be ordered.
 *      //Negative values mean that the order should be reverted
 *      defaultSortIndex: -3
 *  })
 */
import m from 'mithril';
import prop from 'mithril/stream';
import _ from 'underscore';
import models from '../models';
import h from '../h';

const projectDataTable = {
    oninit: function(vnode) {
        const table = prop(vnode.attrs.table),
            sortIndex = prop(-1);

        const comparator = (a, b) => {
            let idx = sortIndex(),
                // Check if a custom comparator is used => Read component description
                x = (_.isArray(a[idx]) && a[idx].length > 1) ? a[idx][0] : a[idx],
                y = (_.isArray(b[idx]) && b[idx].length > 1) ? b[idx][0] : b[idx];

            if (x < y) {
                return -1;
            }
            if (y < x) {
                return 1;
            }
            return 0;
        };

        const sortTable = (idx) => {
            let header = _.first(table()),
                body;
            if (sortIndex() === idx) {
                body = _.rest(table()).reverse();
            } else {
                sortIndex(idx);
                body = _.rest(table()).sort(comparator);
            }

            table(_.union([header], body));
        };

        sortTable(Math.abs(vnode.attrs.defaultSortIndex) || 0);

        if (vnode.attrs.defaultSortIndex < 0) {
            sortTable(Math.abs(vnode.attrs.defaultSortIndex) || 0);
        }

        vnode.state = {
            table,
            sortTable
        };
    },
    view: function({state, attrs}) {
        const header = _.first(state.table()),
            body = _.rest(state.table());
        return m('.table-outer.u-marginbottom-60', [
            m('.w-row.table-row.fontweight-semibold.fontsize-smaller.header',
                _.map(header, (heading, idx) => {
                    const sort = () => state.sortTable(idx);
                    return m('.w-col.w-col-4.w-col-small-4.w-col-tiny-4.table-col', [
                        m('a.link-hidden[href="javascript:void(0);"]', {
                            onclick: sort
                        }, [
                            `${heading} `, m('span.fa.fa-sort')
                        ])
                    ]);
                })
            ), m('.table-inner.fontsize-small',
                _.map(body, rowData => m('.w-row.table-row',
                        _.map(rowData, (row) => {
                            // Check if a custom comparator is used => Read component description
                            row = (_.isArray(row) && row.length > 1) ? row[1] : row;
                            return m('.w-col.w-col-4.w-col-small-4.w-col-tiny-4.table-col', [
                                m('div', row)
                            ]);
                        })
                    ))
            )
        ]);
    }
};

export default projectDataTable;
