/**
 * window.c.CategoryButton component
 * Return a link with a btn-category class.
 * It uses a category parameter.
 *
 * Example:
 * m.component(c.CategoryButton, {
 *     category: {
 *         id: 1,
 *         name: 'Video',
 *         online_projects: 1
 *     }
 * })
 */
import m from 'mithril';

const categoryButton = {
    view: function({attrs}) {
        const category = attrs.category;

        return m('.w-col.w-col-2.w-col-small-6.w-col-tiny-6', [
            m(`a.w-inline-block.btn-category[href='#by_category_id/${category.id}']`, [
                m('div', [
                    category.name,
                    m('span.badge.explore', category.online_projects)
                ])
            ])
        ]);
    }
};

export default categoryButton;
