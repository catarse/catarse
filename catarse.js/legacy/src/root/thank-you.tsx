import m from 'mithril';
import prop from 'mithril/stream';
import _ from 'underscore';
import h from '../h';
import facebookButton from '../c/facebook-button';
import projectShareBox from '../c/project-share-box';
import projectRow from '../c/project-row';
import userVM from '../vms/user-vm';
import projectVM from '../vms/project-vm';
import pixCard from '../c/pix-card';
import { getCurrentUserCached } from '../shared/services/user/get-current-user-cached';

const { CatarseAnalytics } = window;

const I18nScope = _.partial(h.i18nScope, 'projects.contributions');

const thankYou = {
    oninit: function (vnode) {
        const {
            ViewContentEvent,
            PurchaseEvent
        } = projectVM;

        projectVM.sendPageViewForCurrentProject(vnode.attrs.project_id, [ViewContentEvent(), PurchaseEvent()]);

        const recommendedProjects = vnode.attrs.recommended_projects || userVM.getUserRecommendedProjects(),
            isSlip = vnode.attrs.contribution && !_.isEmpty(vnode.attrs.contribution.slip_url),
            isPix = vnode.attrs.contribution && !_.isEmpty(vnode.attrs.contribution.pix_qr_code),
            sendContributionCreationData = () => {
                const analyticsData = {
                    cat: 'contribution_creation',
                    act: 'contribution_created',
                    extraData: {
                        project_id: vnode.attrs.contribution.project.id,
                        contribution_id: vnode.attrs.contribution.contribution_id
                    }
                };
                h.analytics.event(analyticsData)();
            };

        const setEvents = () => {
            sendContributionCreationData();

            CatarseAnalytics.event({
                cat: 'contribution_finish',
                act: 'contribution_finished',
                lbl: isSlip ? 'slip' : isPix ? 'pix' : 'creditcard',
                val: vnode.attrs.contribution.value,
                extraData: {
                    contribution_id: vnode.attrs.contribution.contribution_id
                }
            });

            CatarseAnalytics.checkout(
                `${vnode.attrs.contribution.contribution_id}`,
                `[${vnode.attrs.contribution.project.permalink}] ${vnode.attrs.contribution.reward ? vnode.attrs.contribution.reward.minimum_value : '10'} [${isSlip ? 'slip' : 'creditcard'}]`,
                `${vnode.attrs.contribution.reward ? vnode.attrs.contribution.reward.reward_id : ''}`,
                `${vnode.attrs.contribution.project.category}`,
                `${vnode.attrs.contribution.value}`,
                `${vnode.attrs.contribution.value * vnode.attrs.contribution.project.service_fee}`
            );
        };

        vnode.state = {
            setEvents,
            displayShareBox: h.toggleProp(false, true),
            isSlip,
            isPix,
            recommendedProjects
        };
    },
    view: function ({ state, attrs }) {
        const currentUser = getCurrentUserCached();
        const projectUrl = `${window.location.origin}/${attrs.contribution.project.permalink}`
        const facebookUrl = `https://www.catarse.me/${attrs.contribution.project.permalink}?ref=ctrse_thankyou&utm_source=facebook.com&utm_medium=social&utm_campaign=ctrse_thankyou`;
        const whatsappShareLink = h.isMobile() ? `whatsapp://send?text=${encodeURIComponent(`${projectUrl}?utm_source=whatsapp&utm_medium=social&utm_campaign=project_share_simplified`)}` : `https://api.whatsapp.com/send?text=${encodeURIComponent(`${projectUrl}?utm_source=whatsapp&utm_medium=social&utm_campaign=project_share_simplified`)}`
        const twitterUrl = `https://twitter.com/intent/tweet?text=Acabei%20de%20apoiar%20o%20projeto%20${encodeURIComponent(attrs.contribution.project.name)}%20https://www.catarse.me/${attrs.contribution.project.permalink}%3Fref%3Dctrse_thankyou%26utm_source%3Dtwitter%26utm_medium%3Dsocial%26utm_campaign%3Dctrse_thankyou`;
        return m('#thank-you', { oncreate: state.setEvents }, [
            m('.page-header.u-marginbottom-30',
                m('.w-container',
                    m('.thanks-header',
                        m('.thanks-header-title-wrapper',
                            [
                                m('.thanks-thumb-wrapper',
                                    m(`img.thumb.u-round[src='${attrs.contribution.project.user_thumb}']`)
                                ),
                                m('#thank-you.thanks-header-title',
                                    m('.fontsize-large.text-success.lineheight-tighter.u-marginbottom-10.fontweight-semibold',
                                        state.isSlip || state.isPix ?
                                        window.I18n.t('thank_you_slip.thank_you', I18nScope()) : window.I18n.t('thank_you.thank_you', I18nScope())
                                    ),
                                    m('.thanks-header-instructions-wrapper',
                                        m('.thanks-header-instructions',
                                            m('.fontsize-smaller',
                                                state.isSlip || state.isPix ? (
                                                    m.trust(window.I18n.t(
                                                    state.isSlip ? 'thank_you_slip.thank_you_text_html' : 'thank_you_pix.thank_you_pix_html',
                                                    I18nScope({
                                                        email: attrs.contribution.contribution_email,
                                                    })))
                                                ) :
                                                m.trust(window.I18n.t('thank_you.thank_you_text_html',
                                                    I18nScope({
                                                        email: attrs.contribution.contribution_email,
                                                })))
                                            )
                                        ),
                                        m('.fontsize-smallest.alt-link',
                                            m.trust(window.I18n.t('thank_you.another_email_html',
                                                I18nScope({
                                                    link_email: `/${window.I18n.locale}/users/${currentUser.id}/edit#about_me`
                                                }))
                                            )
                                        )
                                    )
                                )
                            ]
                        ),
                        state.isSlip || state.isPix ? '' :
                            m('.thanks-header-share',
                                m('.divider.u-margintop-20.u-marginbottom-20'),
                                m('.fontsize-smaller.fontweight-semibold.fontcolor-secondary.u-marginbottom-10.u-text-center.w-hidden-medium.w-hidden-small',
                                    'Que tal compartilhar o projeto?'
                                ),
                                [
                                    (
                                        !h.isMobile() &&
                                        m('.w-row.w-hidden-medium.w-hidden-small.w-hidden-tiny',
                                            [
                                                m('.u-marginbottom-10.w-col.w-col-4', m(facebookButton, {
                                                    class: 'thanks-margin',
                                                    url: facebookUrl,
                                                    medium: true
                                                })),
                                                m('.u-marginbottom-10.w-col.w-col-4', [
                                                    m('a.btn.btn-medium[data-action="share/whatsapp/share"]', {
                                                        href: whatsappShareLink
                                                    }, [m('span.fa.fa-whatsapp'), ' Whatsapp'])
                                                ]),
                                                m('.u-marginbottom-10.w-col.w-col-4',
                                                    m(`a.btn.btn-medium.btn-tweet[href="${twitterUrl}"][target="_blank"]`, [
                                                        m('span.fa.fa-twitter'),
                                                        ' Twitter'
                                                    ])
                                                )
                                            ]
                                        )
                                    ),
                                    m('.w-hidden-main.w-hidden-medium', [
                                        m('.u-marginbottom-30.u-text-center-small-only', m('button.btn.btn-large.btn-terciary.u-marginbottom-40', {
                                            onclick: state.displayShareBox.toggle
                                        }, 'Compartilhe')),
                                        state.displayShareBox() ? m(projectShareBox, {
                                            // Mocking a project prop
                                            project: prop({
                                                permalink: attrs.contribution.project.permalink,
                                                name: attrs.contribution.project.name
                                            }),
                                            displayShareBox: state.displayShareBox,
                                            utm: 'ctrse_thankyou',
                                            ref: 'ctrse_thankyou'
                                        }) : ''
                                    ])
                                ]
                            )
                    )
                )
            ),
            m('.section.u-marginbottom-40',
                m('.w-container',
                    state.isSlip ? m('.w-row',
                        m('.w-col.w-col-8.w-col-offset-2',
                            m('iframe.slip', {
                                src: attrs.contribution.slip_url,
                                width: '100%',
                                height: '905px',
                                frameborder: '0',
                                style: 'overflow: hidden;'
                            })
                        )
                    ) :
                    (
                        state.isPix ? m(pixCard, {
                            pix_qr_code: attrs.contribution.pix_qr_code,
                            pix_key: attrs.contribution.pix_key
                        }) :
                        [
                            m('.fontsize-large.fontweight-semibold.u-marginbottom-30.u-text-center',
                                window.I18n.t('thank_you.project_recommendations', I18nScope())
                            ),
                            m(projectRow, {
                                collection: state.recommendedProjects,
                                ref: 'ctrse_thankyou_r'
                            })
                        ]
                    ),
                )
            )
        ]);
    }
};

export default thankYou;
