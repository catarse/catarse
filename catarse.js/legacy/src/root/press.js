import m from 'mithril';
import prop from 'mithril/stream';
import _ from 'underscore';
import { catarse } from '../api';
import h from '../h';
import models from '../models';

const I18nScope = _.partial(h.i18nScope, 'pages.press');
const press = {
    oninit: function(vnode) {
        const stats = prop([]);
        const loader = catarse.loader;
        const statsLoader = loader(models.statistic.getRowOptions());

        statsLoader.load().then(stats);

        vnode.state = {
            stats
        };
    },
    view: function({state}) {
        const stats = _.first(state.stats());

        return m('#press', [
            m('.hero-jobs.hero-medium',
                m('.w-container.u-text-center', [
                    m('img.icon-hero[alt=\'Icon assets\'][src=\'/assets/icon-assets-98f4556940e31b239cdd5fbdd993b5d5ed3bf67dcc3164b805e224d22e1340b7.png\']'),
                    m('.u-text-center.u-marginbottom-20.fontsize-largest',
                        window.I18n.t('page-title', I18nScope())
                    )
                ])
            ),
            m('.section-large.bg-gray',
                m('.w-container',
                    m('.w-row',
                        m('.w-col.w-col-8.w-col-push-2',
                            m('.u-marginbottom-20.fontsize-large',
                                window.I18n.t('abstract.title', I18nScope())
                            )
                        )
                    )
                )
            ),
            m('.section-large',
                m('.w-container',
                    m('.w-row',
                        m('.w-col.w-col-8.w-col-push-2', [
                            m('.fontsize-large.fontweight-semibold.u-marginbottom-10',
                                window.I18n.t('history.title', I18nScope())
                            ),
                            m('.fontsize-large.u-marginbottom-20',
                                window.I18n.t('history.subtitle', I18nScope())
                            ),
                            m.trust(window.I18n.t('history.cta_html', I18nScope()))
                        ])
                    )
                )
            ),
            m('.section-large.bg-gray',
                m('.w-container',
                    m('.w-row',
                        m('.w-col.w-col-8.w-col-push-2', [
                            m('.fontsize-large.fontweight-semibold.u-marginbottom-10',
                                window.I18n.t('stats.title', I18nScope())
                            ),
                            m('.fontsize-large.u-marginbottom-40',
                                window.I18n.t('stats.subtitle', I18nScope())
                            ),
                            m('.w-row.w.hidden-small.u-text-center.u-marginbottom-40', [
                                m('.w-col.w-col-4.u-marginbottom-20', [
                                    m('.text-success.lineheight-loose.fontsize-larger',
                                        h.formatNumber(stats.total_contributors, 0, 3)
                                    ),
                                    m('.fontsize-smaller', m.trust(window.I18n.t('stats.people_html', I18nScope())))
                                ]),
                                m('.w-col.w-col-4.u-marginbottom-20', [
                                    m('.text-success.lineheight-loose.fontsize-larger',
                                        h.formatNumber(stats.total_projects_success, 0, 3)
                                    ),
                                    m('.fontsize-smaller', m.trust(window.I18n.t('stats.projects_html', I18nScope())))
                                ]),
                                m('.w-col.w-col-4.u-marginbottom-20', [
                                    m('.text-success.lineheight-loose.fontsize-larger',
                                        `${stats.total_contributed.toString().slice(0, 2)} milhões`
                                    ),
                                    m('.fontsize-smaller', m.trust(window.I18n.t('stats.money_html', I18nScope())))
                                ])
                            ]),
                            m('a.alt-link.fontsize-large[href=\'https://www.catarse.me/dbhero/dataclips/fa0d3570-9fa7-4af3-b070-2b2e386ef060\'][target=\'_blank\']', [
                                m.trust(window.I18n.t('stats.cta_html', I18nScope()))
                            ])
                        ])
                    )
                )
            ),
            m('.section-large',
                m('.w-container', [
                    m('.w-row.u-marginbottom-30.u-text-center',
                        m('.w-col.w-col-8.w-col-push-2', [
                            m('div',
                                m('img[alt=\'Logo catarse press\'][src=\'/assets/logo-catarse-press-2f2dad49d3e5b256c29e136673b4c4f543c03e0d5548d351ae5a8d1e6e3d2645.png\']')
                            ),
                            m('.fontsize-base',
                                window.I18n.t('assets.title', I18nScope())
                            )
                        ])
                    ),
                    m('.w-row',
                        m('.w-col.w-col-4.w-col-push-4.u-text-center',
                            m('a.alt-link.fontsize-large[href=\'https://www.catarse.me/assets\'][target=\'_blank\']', [
                                m.trust(window.I18n.t('assets.cta_html', I18nScope()))
                            ])
                        )
                    )
                ])
            ),
            m('.section-large.bg-projectgrid',
                m('.w-container', [
                    m('.fontsize-large.u-text-center.fontweight-semibold.u-marginbottom-30',
                        window.I18n.t('social.title', I18nScope())
                    ),
                    m('.w-row', [
                        m('.w-col.w-col-3',
                            m('a.btn.btn-dark.btn-large.u-marginbottom-10[href=\'https://www.facebook.com/Catarse.me\'][target=\'_blank\']', [
                                m('span.fa.fa-facebook'),
                                ' Facebook'
                            ])
                        ),
                        m('.w-col.w-col-3',
                            m('a.btn.btn-dark.btn-large.u-marginbottom-10[href=\'https://twitter.com/catarse\'][target=\'_blank\']', [
                                m('span.fa.fa-twitter'),
                                ' Twitter'
                            ])
                        ),
                        m('.w-col.w-col-3',
                            m('a.btn.btn-dark.btn-large.u-marginbottom-10[href=\'https://instagram.com/catarse/\'][target=\'_blank\']', [
                                m('span.fa.fa-instagram'),
                                ' Instagram'
                            ])
                        ),
                        m('.w-col.w-col-3',
                            m('a.btn.btn-dark.btn-large.u-marginbottom-10[href=\'http://blog.catarse.me/\'][target=\'_blank\']', [
                                m('span.fa.fa-rss'),
                                ' Blog do Catarse'
                            ])
                        )
                    ])
                ])
            ),
            m('.section-large.bg-blue-one.fontcolor-negative',
                m('.w-container',
                    m('.w-row',
                        m('.w-col.w-col-6.w-col-push-3', [
                            m('.fontsize-large.fontweight-semibold.u-text-center.u-marginbottom-30',
                                window.I18n.t('social.news', I18nScope())
                            ),
                            m('.w-form',
                                m(`form[accept-charset='UTF-8'][action='${h.getNewsletterUrl()}'][id='mailee-form'][method='post']`, [
                                    m('.w-form.footer-newsletter',
                                        m('input.w-input.text-field.prefix[id=\'EMAIL\'][label=\'email\'][name=\'EMAIL\'][placeholder=\'Digite seu email\'][type=\'email\']')
                                    ),
                                    m('button.w-inline-block.btn.btn-edit.postfix.btn-attached[type=\'submit\']',
                                        m('img.footer-news-icon[alt=\'Icon newsletter\'][src=\'/assets/catarse_bootstrap/icon-newsletter-9c3ff92b6137fbdb9d928ecdb34c88948277a32cdde3e5b525e97d57735210f5.png\']')
                                    )
                                ])
                            )
                        ])
                    )
                )
            ),
            m('.section-large.bg-gray.before-footer',
                m('.w-container',
                    m('.w-row.u-text-center',
                        m('.w-col.w-col-8.w-col-push-2', [
                            m('.fontsize-larger.fontweight-semibold.u-marginbottom-10',
                                window.I18n.t('email.title', I18nScope())
                            ),
                            m('div',
                                m(`a.alt-link.fontsize-large[href='mailto:${window.I18n.t('email.cta', I18nScope())}']`,
                                    window.I18n.t('email.cta', I18nScope())
                                )
                            )
                        ])
                    )
                )
            )
        ]);
    }
};

export default press;
