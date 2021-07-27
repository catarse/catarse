import m from 'mithril';
import prop from 'mithril/stream';
import _ from 'underscore';
import h from '../h';
import facebookButton from '../c/facebook-button';
import projectShareBox from '../c/project-share-box';
import projectRow from '../c/project-row';
import UserVM from '../vms/user-vm';
import projectVM from '../vms/project-vm';
import CommonPaymentVM from '../vms/common-payment-vm';
import { getCurrentUserCached } from '../shared/services/user/get-current-user-cached';
import { getUserDetailsWithUserId } from '../shared/services/user/get-updated-current-user';

const I18nScope = _.partial(h.i18nScope, 'projects.contributions');
const ProjectsSubscriptionThankYou = {
    oninit: function(vnode) {

        const {
            ViewContentEvent,
            SubscribeEvent
        } = projectVM;

        projectVM.sendPageViewForCurrentProject(vnode.attrs.project_id, [ ViewContentEvent(), SubscribeEvent() ]);

        const paymentMethod = m.route.param('payment_method');
        const paymentConfirmed = JSON.parse(m.route.param('payment_confirmed'));
        const paymentId = m.route.param('payment_id');
        const paymentData = prop({});
        const error = prop(false);
        const projectId = m.route.param('project_id');
        const isEdit = m.route.param('is_edit');
        const project = prop({});
        const projectUser = prop();
        const recommendedProjects = UserVM.getUserRecommendedProjects();
        const sendSubscriptionDataToAnalyticsInterceptingPaymentInfoRequest = (payData) => {
            const analyticsData = {
                cat: isEdit ? 'subscription_edition' : 'subscription_creation',
                act: isEdit ? 'subscription_edited' : 'subscription_created',
                extraData: {
                    project_id: projectId,
                    subscription_id: payData.subscription_id
                }
            };
            h.analytics.event(analyticsData)();
            return payData;
        };

        prop
            .merge([paymentData, project, projectUser, error])
            .map(() => {
                h.scrollTop();
                m.redraw();
            });

        if (paymentId) {
            CommonPaymentVM
                .paymentInfo(paymentId)
                .then(sendSubscriptionDataToAnalyticsInterceptingPaymentInfoRequest)
                .then(paymentData).catch(() => error(true));
        }

        const loadProjectAndItsUser = async () => {
            try {
                const projectsData = await projectVM.fetchProject(projectId, false)
                const firstProject = _.first(projectsData)
                project(firstProject);
                const projectUserDetails = await getUserDetailsWithUserId(firstProject.user.id)
                projectUser(projectUserDetails)
                return projectUser
            } catch (error) {
                h.captureException(error)
                error(true)
            }
        }

        loadProjectAndItsUser().then()

        vnode.state = {
            displayShareBox: h.toggleProp(false, true),
            recommendedProjects,
            paymentMethod,
            paymentConfirmed,
            project,
            projectUser,
            paymentData,
            error,
            isEdit
        };
    },
    view: function({state, attrs}) {
        const project = state.project();
        const user = getCurrentUserCached();
        const projectUser = state.projectUser();
        const projectUrl = `${window.location.origin}/${project.permalink}`
        const whatsappShareLink = h.isMobile() ? `whatsapp://send?text=${encodeURIComponent(`${projectUrl}?utm_source=whatsapp&utm_medium=social&utm_campaign=project_share_simplified`)}` : `https://api.whatsapp.com/send?text=${encodeURIComponent(`${projectUrl}?utm_source=whatsapp&utm_medium=social&utm_campaign=project_share_simplified`)}`

        return m('#thank-you', !project ? h.loader() : [
            m('.page-header.u-marginbottom-30',
                m('.w-container',
                    m('.thanks-header',
                        m('.thanks-header-title-wrapper', [
                            m('.thanks-thumb-wrapper',
                                projectUser ? m(`img.thumb.u-round[src='${projectUser.profile_img_thumbnail}']`) : h.loader()
                            ),
                            m('.thanks-header-title', [
                                m('.fontsize-large.text-success.lineheight-tighter.u-marginbottom-10.fontweight-semibold',
                                    m.trust(
                                        window.I18n.t(
                                            state.isEdit
                                            ? 'thank_you.subscription_edit.thank_you'
                                            : state.paymentMethod === 'credit_card'
                                                ? 'thank_you.thank_you' : 'thank_you_slip.thank_you',
                                    I18nScope()
                                    ))
                                ),
                                m('.thanks-header-instructions-wrapper',
                                    m('.thanks-header-instructions',
                                        m('.fontsize-smaller',
                                            m.trust(
                                                window.I18n.t(
                                                    state.isEdit
                                                    ? 'thank_you.subscription_edit.text_html'
                                                    : state.paymentMethod === 'credit_card'
                                                        ? 'thank_you.thank_you_text_html' : 'thank_you_slip.thank_you_text_html',
                                            I18nScope({
                                                email: user.email
                                            })))
                                        )
                                    ),
                                    m('.fontsize-smallest.alt-link',
                                        m.trust(window.I18n.t('thank_you.another_email_html',
                                            I18nScope({
                                                link_email: `/${window.I18n.locale}/users/${user.id}/edit#about_me`
                                            }))
                                        )
                                    )
                                )
                            ])
                        ]),
                        state.isEdit || state.paymentMethod === 'credit_card' ?
                        m('.thanks-header-share',
                            m('.divider.u-margintop-20.u-marginbottom-20'),
                            m('.fontsize-smaller.fontweight-semibold.fontcolor-secondary.u-marginbottom-10.u-text-center.w-hidden-medium.w-hidden-small',
                                'Que tal compartilhar o projeto?'
                            ),
                            (
                                !h.isMobile() &&
                                m('.w-row.w-hidden-medium.w-hidden-small.w-hidden-tiny', [
                                    m('.u-marginbottom-10.w-col.w-col-4', m(facebookButton, {
                                        class: 'thanks-margin',
                                        url: `https://www.catarse.me/${project.permalink}?ref=ctrse_thankyou&utm_source=facebook.com&utm_medium=social&utm_campaign=project_share`,
                                        medium: true
                                    })),
                                    m('.u-marginbottom-10.w-col.w-col-4', [
                                        m('a.btn.btn-medium[data-action="share/whatsapp/share"]', {
                                            href: whatsappShareLink
                                        }, [m('span.fa.fa-whatsapp'), ' Whatsapp'])
                                    ]),
                                    m('.u-marginbottom-10.w-col.w-col-4',
                                        m(`a.btn.btn-medium.btn-tweet[href="https://twitter.com/intent/tweet?text=Acabei%20de%20apoiar%20o%20projeto%20${encodeURIComponent(project.name)}%20https://www.catarse.me/${project.permalink}%3Fref%3Dtwitter%26utm_source%3Dtwitter.com%26utm_medium%3Dsocial%26utm_campaign%3Dproject_share"][target="_blank"]`, [
                                        m('span.fa.fa-twitter'), ' Twitter'
                                    ]))
                                ])
                            ),
                            m('.w-hidden-main.w-hidden-medium', [
                                m('.u-marginbottom-30.u-text-center-small-only', m('button.btn.btn-large.btn-terciary.u-marginbottom-40', {
                                    onclick: state.displayShareBox.toggle
                                }, 'Compartilhe')),
                                state.displayShareBox() ? m(projectShareBox, {
                                    project: prop({
                                        permalink: project.permalink,
                                        name: project.name
                                    }),
                                    displayShareBox: state.displayShareBox
                                }) : ''
                            ])
                        ) : ''

                    )
                )
            ),
            state.error()
                ? m('.w-row',
                    m('.w-col.w-col-8.w-col-offset-2',
                        m('.card.card-error.u-radius.zindex-10.u-marginbottom-30.fontsize-smaller', window.I18n.translate('thank_you.thank_you_error', I18nScope()))
                    )
                )
                : state.paymentData().boleto_url
                    ? m('.w-row',
                        m('.w-col.w-col-8.w-col-offset-2',
                            m('iframe.slip', {
                                src: state.paymentData().boleto_url,
                                width: '100%',
                                height: '905px',
                                frameborder: '0',
                                style: 'overflow: hidden;'
                            })
                        )
                    ) : m('.section.u-marginbottom-40',
                        m('.w-container', [
                            m('.fontsize-large.fontweight-semibold.u-marginbottom-30.u-text-center',
                                window.I18n.t('thank_you.project_recommendations', I18nScope())
                            ),
                            m(projectRow, {
                                collection: state.recommendedProjects,
                                ref: 'ctrse_thankyou_r'
                            })
                        ])
                    )
        ]);
    }
};

export default ProjectsSubscriptionThankYou;
