import m from 'mithril';
import _ from 'underscore';
import h from '../h';
import HeaderMenuSearch from '../c/header-menu-search';
import menuProfile from '../c/menu-profile';
import models from '../models';
import { catarse } from '../api';

import { ExploreLightBox } from '../experiments/c/explore-light-box';

const menu = {
    oninit: function(vnode) {
        const exploreButtonBehavoir = h.RedrawStream((/** @type {Event} */ event) => {
            event.preventDefault();
            m.route.set('/explore?ref=ctrse_header&filter=all');
        });
        const displayLightBox = h.RedrawStream(false);
        const user = h.getUser();
        const menuCss = () => {
            return `${vnode.attrs.menuTransparency ? 'overlayer' : ''} ${(vnode.attrs.withAlert || vnode.attrs.withFixedAlert) ? 'with-global-alert' : ''}`;
        };
        const homeAttrs = () => {
            if (vnode.attrs.absoluteHome) {
                return {
                    href: h.rootUrl(),
                    oncreate: m.route.link
                };
            }
            return {
                oncreate: m.route.link
            };
        };

        const filters = catarse.filtersVM;
        const categories = h.RedrawStream([]);
        models.category.getPageWithToken(filters({}).order({ name: 'asc' }).parameters()).then(categories);

        window.optimizeObserver.addListener((variantName) => {            
            if (variantName === 'Explore Light Box') {
                exploreButtonBehavoir((/** @type {Event} */ event) => {
                    event.preventDefault();
                    displayLightBox(true);
                });
            }
        });
        
        vnode.state = {
            user,
            menuCss,
            homeAttrs,
            exploreButtonBehavoir,
            displayLightBox,
            categories,
        };
    },
    view: function({state, attrs}) {

        const exploreButtonBehavoir = state.exploreButtonBehavoir;
        const displayLightBox = state.displayLightBox;
        const categories = state.categories;

        return m('header.main-header', {
            class: state.menuCss()
        }, [

            (displayLightBox() ? m(ExploreLightBox, { onClose: () => displayLightBox(false), categories }) : null),

            m('.w-row', [
                m('.w-clearfix.w-col.w-col-8.w-col-small-8.w-col-tiny-8',
                    [
                        m('a.header-logo.w-inline-block[href=\'/?ref=ctrse_header\'][title=\'Catarse\']',
                            state.homeAttrs(),
                            m('img[alt=\'Logo big\'][src=\'/assets/catarse_bootstrap/logo_big.png\']')
                        ),
                        attrs.menuShort ? '' : m('div#menu-components', [
                            m('a.w-hidden-small.w-hidden-tiny.header-link.w-nav-link[href=\'https://crowdfunding.catarse.me/comece\']', 'Comece seu projeto'),
                            m(`a.w-hidden-small.w-hidden-tiny.header-link.w-nav-link[href=\'/${window.I18n.locale}/explore?ref=ctrse_header\']`, { onclick: exploreButtonBehavoir() }, 
                                'Explore'
                            ),
                            m(HeaderMenuSearch)
                        ])
                    ]
                ),
                m('.text-align-right.w-col.w-col-4.w-col-small-4.w-col-tiny-4', [
                    state.user ? m(menuProfile, { user: state.user }) : m(`a.w-nav-link.header-link.w-nav-link.btn-edit.u-right[href=\'/${window.I18n.locale}/login?ref=ctrse_header\']`, 'Login'),
                ])

            ]),
            attrs.menuShort ? '' : m('.header-controls-mobile.w-hidden-main.w-hidden-medium',
                [
                    m(`a.header-link.w-nav-link[href=\'/${window.I18n.locale}/start?ref=ctrse_header\']`,
                        { onclick: () => m.route.set('/start') },
                        'Comece seu projeto'
                    ),
                    m(`a.header-link.w-nav-link[href=\'/${window.I18n.locale}/explore?ref=ctrse_header\']`,
                        { onclick: exploreButtonBehavoir() },
                        'Explore'
                    )
                ]
            )
        ]);
    }
};

export default menu;
