import m from 'mithril';
import prop from 'mithril/stream';
import { catarse } from '../api';
import _ from 'underscore';
import h from '../h';
import models from '../models';
import projectDashboardMenu from '../c/project-dashboard-menu';
import postsPreview from '../c/posts-preview';
import rewardVM from '../vms/reward-vm';
import projectVM from '../vms/project-vm';
import popNotification from '../c/pop-notification';
import postForRewardCheckbox from '../c/post-for-reward-checkbox';
import postEntry from '../c/post-entry';

const I18nScope = _.partial(h.i18nScope, 'projects.dashboard_posts');

const posts = {
    oninit: function(vnode) {
        let deleteFormSubmit;
        const showPreview = prop(false),
            willSelectRewards = prop(false),
            isProjectLoaded = prop(false),
            isProjectPostsLoaded = prop(false),
            showSuccess = prop(false),
            showError = prop(false),
            selectedRewardsHasError = prop(false),
            titleHasError = prop(false),
            commentHasError = prop(false),
            projectPosts = prop(),
            loader = catarse.loaderWithToken,
            errors = prop(''),
            fields = {
                title: prop(''),
                comment_html: prop(''),
                recipients: prop('public'),
                radio_checked: prop(false),
                paid_rewards: prop([]),
                get_selected_rewards_text: () => {
                    if (fields.recipients === 'public') {
                        return window.I18n.t(`everyone_${project.mode}`, I18nScope())
                    }
                    else if (fields.recipients === 'backers') {
                        return window.I18n.t(`backers_${project.mode}`, I18nScope())
                    }
                    else {
                        return fields
                            .get_selected_rewards()
                            .map(rc => `R$${h.formatNumber(parseInt(rc.reward.data.minimum_value))}${rc.reward.data.title ? ` - ${rc.reward.data.title}` : ''}`).join(', ');
                    }                    
                },
                get_selected_rewards: () => {                    
                    return _.filter(fields.paid_rewards(), rc => rc.checked());
                },
                get_selected_reward_ids: () => {
                    const project = _.first(projectDetails());
                    const isSubscription = projectVM.isSubscription(project);
                    const getRewardId = (r) => isSubscription ? r.external_id : r.id;
                    return _.map(fields.get_selected_rewards(), rc => getRewardId(rc.reward));
                }                    
            },
            filterVM = catarse.filtersVM({
                project_id: 'eq'
            }),
            validateTitle = () => {
                const title = String(fields.title());
                if (title.length === 0) {
                    titleHasError(true);
                }

                return !titleHasError();
            },
            validateComment = () => {
                const comment = String(fields.comment_html());
                if (comment.length === 0) {
                    commentHasError(true);
                }

                return !commentHasError();
            },
            validateSelectedRewards = () => {
                const wants_to_send_to_ones_who_paid_for_rewards = fields.recipients() === 'rewards';
                const wants_to_send_to_backers_or_public = !wants_to_send_to_ones_who_paid_for_rewards;
                const has_selected_at_least_one_reward = fields.get_selected_rewards().length > 0;
                const validation_is_ok = wants_to_send_to_backers_or_public || (wants_to_send_to_ones_who_paid_for_rewards && has_selected_at_least_one_reward);
                selectedRewardsHasError(!validation_is_ok);

                return validation_is_ok;
            },
            togglePreview = () => {
                if (!validateTitle()) {
                    errors('Título não pode ficar em branco.');
                    showError(true);
                } else if (!validateComment()) {
                    errors('Mensagem não pode ficar em branco.');
                    showError(true);
                } else if (!validateSelectedRewards()) {
                    errors('É necessário selecionar pelo menos uma recompensa.');
                    showError(true);
                } else {
                    h.scrollTop();
                    showPreview(true);
                }
                return false;
            },
            project_id = vnode.attrs.project_id,
            projectDetails = prop([]),
            rewardText = (rewardId, project) => {
                // @TODO move non-sub rewards to common API
                if (projectVM.isSubscription(project)) {
                    const reward = _.find(rewardVM.rewards(), r => String(r.external_id) === String(rewardId));
                    return `Assinantes da recompensa R$${reward.data.minimum_value / 100} - ${reward.data.title ? reward.data.title : `${reward.data.description.substring(0, 70)}...`}`;
                }
                const reward = _.find(rewardVM.rewards(), r => String(r.id) === String(rewardId));
                return `Apoiadores da recompensa R$${reward.minimum_value} - ${reward.title ? reward.title : `${reward.description.substring(0, 70)}...`}`;
            },
            showRecipientes = (post, project) => {
                if (post.recipients === 'public') {
                    return window.I18n.t(`everyone_${project.mode}`, I18nScope());
                } else if (post.recipients === 'backers') {
                    return window.I18n.t(`backers_${project.mode}`, I18nScope());
                } else if (post.rewards_that_can_access_post && post.rewards_that_can_access_post.length) {
                    const preText = project.mode === 'sub' ? 'Assinantes de ' : 'Apoiadores de ';
                    return preText + _.map(
                        post.rewards_that_can_access_post, 
                        reward => `R$${h.formatNumber(reward.minimum_value)}${reward.title ? ` - ${reward.title}` : ''}`
                    ).join(', ');
                } else {
                    return '...';
                }
            },
            toDeletePost = prop(-1),
            deletePost = post => () => {
                toDeletePost(post.id);
                m.redraw(true);
                deleteFormSubmit();
                return false;
            },
            setPostDeletionForm = (localVnode) => {
                deleteFormSubmit = () => localVnode.dom.submit();
            },
            openedPercentage = post => (Math.floor((post.open_count / post.delivered_count) * 100) || 0);

        models.projectPostDetail.pageSize(false);
        filterVM.project_id(project_id);
        const listVM = catarse.loaderWithToken(models.projectPostDetail.getPageOptions(_.extend(filterVM.parameters(), { order: 'created_at.desc' }))),
            l = loader(models.projectDetail.getRowOptions(filterVM.parameters()));

        listVM.load().then((posts) => {
            projectPosts(posts);
            isProjectPostsLoaded(true);
            h.redraw();
        });

        const filterOnlyPaidRewards = (r) => {
            const project = _.first(projectDetails()),
                isSubscription = projectVM.isSubscription(project);

            return (isSubscription ? r.subscribed_count : r.paid_count > 0) || false;
        };

        const createCheckboxesControlForRewardSelected = (rewards) => {
            const filteredRewards = _.filter(rewards, filterOnlyPaidRewards);
            const paidRewardsSorted = _.sortBy(filteredRewards, pr => parseInt(pr.data.minimum_value));
            const checkboxesArray = paidRewardsSorted.map(pr => { 
                return {
                    checked: h.toggleProp(false, true),
                    reward: pr
                };
            });
            
            fields.paid_rewards(checkboxesArray);
            h.redraw();
            return rewards;
        };

        const addDataFieldToNoCommonRewards = (rewards) => rewards ? rewards.map(r => _.extend(r, { data: r })) : [];
        const remapMinimumValue = (rewards) => rewards.map(r => {            
            r.data.minimum_value = parseInt(r.data.minimum_value) / 100; 
            return r;
        });

        l.load().then((data) => {
            projectDetails(data);
            if (projectVM.isSubscription(_.first(projectDetails()))) {
                rewardVM
                    .fetchCommonRewards(_.first(projectDetails()).common_id)
                    .then(remapMinimumValue)
                    .then(createCheckboxesControlForRewardSelected)
                    .then(() => h.redraw());
                    
            } else {
                rewardVM
                    .fetchRewards(project_id)
                    .then(addDataFieldToNoCommonRewards)
                    .then(createCheckboxesControlForRewardSelected)
                    .then(() => h.redraw());
            }

            isProjectLoaded(true);
        });

        vnode.state = {
            listVM,
            l,
            projectPosts,
            showRecipientes,
            fields,
            showPreview,
            togglePreview,
            project_id,
            deletePost,
            rewardText,
            errors,
            showSuccess,
            selectedRewardsHasError,
            titleHasError,
            commentHasError,
            showError,
            setPostDeletionForm,
            toDeletePost,
            projectDetails,
            openedPercentage,
            isProjectPostsLoaded,
            isProjectLoaded
        };
    },
    view: function({state}) {
        
        const project = _.first(state.projectDetails()),
            isSubscription = projectVM.isSubscription(project),
            recipients = state.fields.recipients;

        return (state.isProjectLoaded() && state.isProjectPostsLoaded()) ? m('.project-posts',
            (project.is_owner_or_admin ? m(projectDashboardMenu, {
                project: prop(project)
            }) : ''),
            state.showPreview() ? m(postsPreview, {
                showError: state.showError,
                showSuccess: state.showSuccess,
                errors: state.errors,
                showPreview: state.showPreview,
                project_id: state.project_id,
                mode: project.mode,
                comment_html: state.fields.comment_html,
                title: state.fields.title,
                recipients: state.fields.recipients(),
                rewards: state.fields.get_selected_reward_ids(),
                confirmationLabel: isSubscription ? 'assinantes' : 'apoiadores',
                rewardText: state.fields.get_selected_rewards_text()
            }) : [
                m(`.w-section.section-product.${project.mode}`),
                (state.showSuccess() ? m(popNotification, {
                    message: window.I18n.t('successful', I18nScope())
                }) : ''),
                (state.showError() ? m(popNotification, {
                    message: state.errors(),
                    error: true
                }) : ''),
                m('.dashboard-header.u-text-center',
                    m('.w-container',
                        m('.w-row', [
                            m('.w-col.w-col-3'),
                            m('.w-col.w-col-6',
                                m('.fontsize-larger.fontweight-semibold.lineheight-tight',
                                    window.I18n.t(`send_a_message_${project.mode}`, I18nScope())
                                )
                            ),
                            m('.w-col.w-col-3')
                        ])
                    )
                ), m('.section', m('.w-container',
                    m('.w-row', [
                        m('.w-col.w-col-1'),
                        m('.w-col.w-col-10', [
                            (
                                isSubscription ? '' :
                                m('.u-marginbottom-60.u-text-center',
                                    m('._w-inline-block.card.fontsize-small.u-radius', [
                                        m('span.fa.fa-lightbulb-o',
                                            ''
                                        ),
                                        ' Veja ótimo motivos para ',
                                        m('a.alt-link[href=\'https://catarse.attach.io/B1AHAGm1x\'][target=\'_blank\']',
                                            'falar com seus apoiadores agora mesmo!'
                                        )
                                    ])
                                )
                            ),
                            m('.card.card-terciary.medium.u-marginbottom-80.w-form', [
                                m('form', [
                                    m('label.field-label.fontweight-semibold',
                                        'Destinatários'
                                    ),


                                    //////////// START DESTINATIONS
                                    m('.u-marginbottom-20', [
                                        // TO EVERYONE
                                        m('.fontsize-small.w-radio', [
                                            m(`input.w-radio-input[type=radio][value='public']`, {
                                                checked: recipients() === 'public',
                                                onchange: m.withAttr('value', recipients)
                                            }),
                                            m('label.w-form-label', {
                                                onclick: () => recipients('public')
                                            }, window.I18n.t(`everyone_${project.mode}`, I18nScope()))
                                        ]),

                                        // TO CONTRIBUTORS/SUBSCRIBERS
                                        m('.fontsize-small.w-radio', [
                                            m(`input.w-radio-input[type=radio][value='backers']`, {
                                                checked: recipients() === 'backers',
                                                onchange: m.withAttr('value', recipients)
                                            }),
                                            m('label.w-form-label', {
                                                onclick: () => recipients('backers')
                                            }, window.I18n.t(`backers_${project.mode}`, I18nScope()))
                                        ]),

                                        // TO SOME CONTRIBUTORS/SUBSCRIBERS
                                        (
                                            state.fields.paid_rewards().length === 0 ? '' :
                                            m('.fontsize-small.w-radio', [
                                                m(`input.w-radio-input[type=radio][value='rewards']`, {
                                                    checked: recipients() === 'rewards',
                                                    onchange: m.withAttr('value', recipients)
                                                }),
                                                m('label.w-form-label', {
                                                    onclick: () => recipients('rewards')
                                                }, window.I18n.t(`backers_some_${project.mode}`, I18nScope()))
                                            ])
                                        ),

                                        // SOME SELECTION CHECKBOXES CONTRIBUTORS/SUBSCRIBERS
                                        (
                                            recipients() !== 'rewards' ? '' : 
                                            m('.card.u-radius', {
                                                class: state.selectedRewardsHasError() ? 'card-message-error' : '',
                                                onclick: () => { 
                                                    state.selectedRewardsHasError(false);
                                                    state.showError(false);
                                                }
                                            },
                                                _.map(state.fields.paid_rewards(), 
                                                    pr => m(postForRewardCheckbox, {
                                                        reward_checkbox: pr.checked,
                                                        reward: pr.reward,
                                                        contributions_count: isSubscription ? pr.reward.subscribed_count : pr.reward.paid_count,
                                                        sublabel: isSubscription ? 'assinantes' : 'apoiadores'
                                                    })
                                                )
                                            )
                                        )
                                    ]),

                                    //////////// END DESTINATIONS

                                    m('label.field-label.fontweight-semibold',
                                        'Título'
                                    ),
                                    m('input.positive.text-field.w-input[id=\'post_title\'][maxlength=\'256\'][type=\'text\']', {
                                        name: 'posts[title]',
                                        value: state.fields.title(),
                                        onfocus: () => {
                                            state.titleHasError(false);
                                            state.showError(false);
                                        },
                                        class: state.titleHasError() ? 'error' : '',
                                        onchange: m.withAttr('value', state.fields.title)
                                    }),
                                    m('label.field-label.fontweight-semibold',
                                        'Texto'
                                    ),
                                    m('.preview-container.u-marginbottom-40', {
                                        class: state.commentHasError() ? 'error' : '',
                                        onclick: () => {
                                            state.commentHasError(false);
                                            state.showError(false);
                                        }
                                    }, h.redactor('posts[comment_html]', state.fields.comment_html)),
                                    m('.u-marginbottom-20.w-row', [
                                        m('.w-col.w-col-3'),
                                        m('.w-sub-col.w-col.w-col-6',
                                            m('button.btn.btn-large', {
                                                onclick: state.togglePreview
                                            },
                                                window.I18n.t('preview', I18nScope())
                                            )
                                        ),
                                        m('.w-col.w-col-3')
                                    ])
                                ])
                            ]),
                            m('.fontsize-large.fontweight-semibold.u-marginbottom-40',
                                'Novidades já enviadas'
                            ),
                            m('.table-outer.u-marginbottom-60', [
                                m('.fontsize-smaller.fontweight-semibold.header.table-row.w-row', [
                                    m('.table-col.w-col.w-col-5',
                                        m('div',
                                            'Título'
                                        )
                                    ),
                                    m('.table-col.u-text-center.w-col.w-col-3',
                                        m('div',
                                            'Enviadas'
                                        )
                                    ),
                                    m('.table-col.u-text-center.w-col.w-col-3',
                                        m('div',
                                            'Abertas'
                                        )
                                    ),
                                    m('.table-col.w-col.w-col-1')
                                ]),
                                (state.projectPosts() ? m('.fontsize-small.table-inner', [
                                    _.map(state.projectPosts(),
                                        post => m(postEntry, {
                                            post,
                                            project,
                                            destinatedTo: state.showRecipientes(post, project),
                                            showOpenPercentage: state.openedPercentage(post),
                                            deletePost: () => state.deletePost(post)
                                        })
                                    ),
                                    m('form.w-hidden', {
                                        action: `/${window.I18n.locale}/projects/${project.project_id}/posts/${state.toDeletePost()}`,
                                        method: 'POST',
                                        oncreate: state.setPostDeletionForm
                                    }, [
                                        m('input[name=\'utf8\'][type=\'hidden\'][value=\'✓\']'),
                                        m('input[name=\'_method\'][type=\'hidden\'][value=\'delete\']'),
                                        m(`input[name='authenticity_token'][type='hidden'][value='${h.authenticityToken()}']`),
                                    ])

                                ]) : h.loader())
                            ])
                        ]),
                        m('.w-col.w-col-1')
                    ])
                ))
            ]) : h.loader();
    }
};

export default posts;
