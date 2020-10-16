import m from 'mithril';
import prop from 'mithril/stream';
import _ from 'underscore';
import h from '../h';
import facebookButton from '../c/facebook-button';
import projectShareBox from '../c/project-share-box';
import projectRow from '../c/project-row';
import userVM from '../vms/user-vm';
import projectVM from '../vms/project-vm';

const { CatarseAnalytics } = window;

const I18nScope = _.partial(h.i18nScope, 'projects.contributions');

const thankYou = {
    oninit: function(vnode) {
        const {
            ViewContentEvent,
            PurchaseEvent
        } = projectVM;
        
        projectVM.sendPageViewForCurrentProject(vnode.attrs.project_id, [ ViewContentEvent(), PurchaseEvent() ]);

        const recommendedProjects = vnode.attrs.recommended_projects || userVM.getUserRecommendedProjects(),
            isSlip = vnode.attrs.contribution && !_.isEmpty(vnode.attrs.contribution.slip_url),
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
                lbl: isSlip ? 'slip' : 'creditcard',
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
            recommendedProjects
        };
    },
    view: function({state, attrs}) {

        return m('#thank-you', { oncreate: state.setEvents }, [
            m('.page-header.u-marginbottom-30',
              m('.w-container',
                m('.w-row',
                  m('.w-col.w-col-10.w-col-push-1',
                      [
                          m('.u-marginbottom-20.u-text-center',
                          m(`img.big.thumb.u-round[src='${attrs.contribution.project.user_thumb}']`)
                         ),
                          m('#thank-you.u-text-center', !state.isSlip ?
                          [
                              m('#creditcard-thank-you.fontsize-larger.text-success.u-marginbottom-20',
                                window.I18n.t('thank_you.thank_you', I18nScope())
                               ),
                              m('.fontsize-base.u-marginbottom-40',
                                m.trust(
                                    window.I18n.t('thank_you.thank_you_text_html',
                                           I18nScope({
                                               total: attrs.contribution.project.total_contributions,
                                               email: attrs.contribution.contribution_email,
                                               link2: `/${window.I18n.locale}/users/${h.getUser().user_id}/edit#contributions`,
                                               link_email: `/${window.I18n.locale}/users/${h.getUser().user_id}/edit#about_me`
                                           })
                                          )
                                )
                               ),
                              m('.fontsize-base.fontweight-semibold.u-marginbottom-20',
                                'Compartilhe com seus amigos e ajude esse projeto a bater a meta!'
                               )
                          ] : [
                              m('#slip-thank-you.fontsize-largest.text-success.u-marginbottom-20', window.I18n.t('thank_you_slip.thank_you', I18nScope())),
                              m('.fontsize-base.u-marginbottom-40',
                                m.trust(window.I18n.t('thank_you_slip.thank_you_text_html',
                                               I18nScope({
                                                   email: attrs.contribution.contribution_email,
                                                   link_email: `/${window.I18n.locale}/users/${h.getUser().user_id}/edit#about_me`
                                               }))))
                          ]
                         ),
                          state.isSlip ? '' : m('.w-row',
                              [
                                  m('.w-hidden-small.w-hidden-tiny',
                                      [
                                          m('.w-sub-col.w-col.w-col-4', m(facebookButton, {
                                              url: `https://www.catarse.me/${attrs.contribution.project.permalink}?ref=ctrse_thankyou&utm_source=facebook.com&utm_medium=social&utm_campaign=project_share`,
                                              big: true
                                          })),
                                          m('.w-sub-col.w-col.w-col-4', m(facebookButton, {
                                              messenger: true,
                                              big: true,
                                              url: `https://www.catarse.me/${attrs.contribution.project.permalink}?ref=ctrse_thankyou&utm_source=facebook.com&utm_medium=messenger&utm_campaign=thanks_share`
                                          })),
                                          m('.w-col.w-col-4', m(`a.btn.btn-large.btn-tweet.u-marginbottom-20[href="https://twitter.com/intent/tweet?text=Acabei%20de%20apoiar%20o%20projeto%20${encodeURIComponent(attrs.contribution.project.name)}%20https://www.catarse.me/${attrs.contribution.project.permalink}%3Fref%3Dtwitter%26utm_source%3Dtwitter.com%26utm_medium%3Dsocial%26utm_campaign%3Dproject_share"][target="_blank"]`, [
                                              m('span.fa.fa-twitter'), ' Twitter'
                                          ]))
                                      ]
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
                                          displayShareBox: state.displayShareBox
                                      }) : ''
                                  ])
                              ]
                                            ),
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
                               ) : [
                                   m('.fontsize-large.fontweight-semibold.u-marginbottom-30.u-text-center',
                                     window.I18n.t('thank_you.project_recommendations', I18nScope())
                                    ),
                                   m(projectRow, {
                                       collection: state.recommendedProjects,
                                       ref: 'ctrse_thankyou_r'
                                   })
                               ]
               )
             )
        ]);
    }
};

export default thankYou;
