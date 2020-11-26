/**
 * window.c.FilterButton component
 * Return a link with a filters class.
 * It uses a href and a title parameter.
 *
 * Example:
 * m.component(c.FilterButton, {
 *     title: 'Filter by category',
 *     href: 'filter_by_category'
 * })
 */

import m from 'mithril';

const filterButton = {
    view: function({attrs}) {
        const title = attrs.title,
            href = attrs.href;
        return m('.w-col.w-col-2.w-col-small-6.w-col-tiny-6', [
            m(`a.w-inline-block.btn-category.filters${title.length > 13 ? '.double-line' : ''}[href='#${href}']`, [
                m('div', [
                    title
                ])
            ])
        ]);
    }
};

export default filterButton;
