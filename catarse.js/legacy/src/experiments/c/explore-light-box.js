import m from 'mithril';
import './explore-light-box.css';
import userVM from '../../vms/user-vm';

/**
 * @typedef ListItem
 * @property {string} label
 * @property {{[key:string] : string}} query
 */

export class ExploreLightBox {

    /**
     * @typedef Attrs
     * @property {() => void} onClose
     * @property {() => Array<{name: string, id: string}>} categories
     */

    /**
     * @param {{attrs: Attrs}} vnode
     */
    view({attrs}) {
        const onClose = attrs.onClose;
        const categories = attrs.categories;
        const closePreventRedirect = (/** @type {Event} */ event) => {
            event.preventDefault();
            onClose();
        };

        const filters = [
            {
                name: 'Projetos que amamos',
                query: {
                    filter: 'projects_we_love',
                }
            },
            {
                name: 'Populares',
                query: {
                    filter: 'all',
                }
            },
            {
                name: 'Projetos COVID-19',
                query: {
                    mode: 'covid_19',
                }
            },
            {
                name: 'Em breve no Catarse',
                query: {
                    filter: 'coming_soon_landing_page',
                }
            },
            userVM.isLoggedIn ? {
                name: 'Projetos Salvos',
                query: {
                    filter: 'active_saved_projects',
                }
            } : null,
            userVM.isLoggedIn ? {
                name: 'Apoiados por amigos',
                query: {
                    filter: 'contributed_by_friends',
                }
            } : null,
            {
                name: 'Recentes',
                query: {
                    filter: 'recent',
                }
            },
            {
                name: 'Reta final',
                query: {
                    filter: 'expiring',
                }
            }
        ].filter(f => f !== null);

        const queryBase = {
            ref: 'ctrse_header',
            utm_source: 'catarse',
            utm_medium: 'ctrse_header',
            utm_campaign: 'testeAB_explorelightbox',
        };

        /**
         * @param {{name: string, keyName: string}} filter
         * @returns {ListItem}
         */
        const mapFiltersToItems = (filter) => {
            return {
                label: filter.name,
                query: filter.query,
            };
        };

        /**
         * @param {{name: string, id: string}} category
         * @returns {ListItem}
         */
        const mapCategoriesToItems = (category) => {
            return {
                label: category.name,
                query: {
                    category_id: category.id,
                }
            };
        };

        return m('div.explore-lightbox',
            m('div.explore-lightbox-container.w-clearfix', [
                m('a.modal-close-container.fa.fa-2x.fa-close.w-inline-block[href="#"]', { onclick: closePreventRedirect }),

                m(ExploreLightBoxList, {
                    title: 'Filtro',
                    items: filters.map(mapFiltersToItems),
                    query: queryBase,
                    onSelect: () => onClose(),
                }),

                m(ExploreLightBoxList, {
                    title: 'Categorias',
                    items: categories().map(mapCategoriesToItems),
                    query: queryBase,
                    onSelect: () => onClose(),
                }),

            ])
        );
    }
}

class ExploreLightBoxList {

    /**
     * @typedef Attrs
     * @property {string} title
     * @property {ListItem[]} items
     * @property {{[key:string] : string}} query
     * @property {(item : ListItem) => void} onSelect
     */

    /**
     * @param {{ attrs: Attrs }} vnode
     */
    view({attrs}) {

        const title = attrs.title;
        const items = attrs.items;
        const query = attrs.query;
        const onSelect = attrs.onSelect;

        return m('div.u-marginbottom-30', [
            m('div.u-margintop-30',
                m('div.fontsize-base.fontcolor-terciary', title)
            ),
            items.map(item => {
                const queryParams = m.buildQueryString(Object.assign({}, query, item.query));
                const navigateUrl = `/${window.I18n.locale}/explore?${queryParams}`;

                return m(ExploreLightBoxListItem, {
                    onSelect: () => onSelect(item),
                    url: navigateUrl,
                    label: item.label,
                });
            })
        ]);
    }
}

class ExploreLightBoxListItem {

    /**
     * @typedef Attrs
     * @property {() => void} onSelect
     * @property {string} url
     * @property {string} label
     */

    /**
     * @param {{ attrs: Attrs }} vnode
     */
    view({attrs}) {
        const label = attrs.label;
        const url = attrs.url;
        const onSelect = attrs.onSelect;

        return m(`a.explore-lightbox-filter-link[href="${url}"]`, {
            onclick: (event) => {
                m.route.set(url);
                event.preventDefault();
                onSelect();
            }
        }, label);
    }
}
