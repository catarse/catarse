import m from 'mithril';
import {
    catarse
} from '../api';
import _ from 'underscore';
import models from '../models';
import h from '../h';

const I18nScope = _.partial(h.i18nScope, 'projects.posts');

const projectPosts = {
    oninit: function(vnode) {
        const listVM = h.createBasicPaginationVMWithAutoRedraw(catarse.paginationVM(models.projectPostDetail));
        const filterVM = catarse.filtersVM({ project_id: 'eq', id: 'eq'});
            
        const scrollTo = (localVnode) => {
            h.animateScrollTo(localVnode.dom);
        };

        filterVM.project_id(vnode.attrs.project().project_id);

        if (_.isNumber(parseInt(vnode.attrs.post_id))) {
            filterVM.id(vnode.attrs.post_id);
        }

        if (!listVM.collection().length) {
            listVM.firstPage(filterVM.parameters()).then(() => m.redraw());
        }

        vnode.state = {
            listVM,
            filterVM,
            scrollTo
        };
    },
    view: function({state, attrs}) {
        const list = state.listVM,
            project = attrs.project() || {},
            postHeader = (post) => _.map(post.rewards_that_can_access_post, r => ` R$${h.formatNumber(r.minimum_value)}${r.title ? ` - ${r.title}` : ''}`),
            postTextSubscription = (post) => `Post exclusivo para assinantes${ post.rewards_that_can_access_post ? ' de' : ''}${postHeader(post)}`,
            postTextContribution = (post) => `Post exclusivo para apoiadores${ post.rewards_that_can_access_post ? ' de' : ''}${postHeader(post)}`,
            minimumValueRewardId = (post) => _.first(_.sortBy(post.rewards_that_can_access_post, r => r.minimum_value)).id;

        return m('#posts.project-posts.w-section', {
            oncreate: state.scrollTo
        }, [
            m('.w-container.u-margintop-20', [
                (project.is_owner_or_admin ? [
                    (!list.isLoading()) ?
                    (_.isEmpty(list.collection()) ? m('.w-hidden-small.w-hidden-tiny', [
                        m('.fontsize-base.u-marginbottom-30.u-margintop-20', 'Toda novidade publicada no Catarse é enviada diretamente para o email de quem já apoiou seu projeto e também fica disponível para visualização no site. Você pode optar por deixá-la pública, ou visível somente para seus apoiadores aqui nesta aba.')
                    ]) : '') : '',
                    m('.w-row.u-marginbottom-20', [
                        m('.w-col.w-col-4.w-col-push-4', [
                            m(`a.btn.btn-edit.btn-small[href='/${window.I18n.locale}/projects/${project.project_id}/posts']`, 'Escrever novidade')
                        ])
                    ])
                ] : ''), 
                (_.map(list.collection(), post => m('.w-row', [
                    _.isEmpty(post.comment_html) ? 
                    [
                        m('.fontsize-small.fontcolor-secondary.u-text-center', h.momentify(post.created_at)),
                        m('p.fontweight-semibold.fontsize-larger.u-text-center.u-marginbottom-30', [
                            m(`a.link-hidden[href="/projects/${post.project_id}/posts/${post.id}#posts"]`, post.title)
                        ]),
                        m('.card.card-message.u-radius.card-big.u-text-center.u-marginbottom-60', [
                            m('.fa.fa-lock.fa-3x.fontcolor-secondary',
                                ''
                            ),
                            project.mode === 'sub' ? [
                                m('.fontsize-base.fontweight-semibold.u-marginbottom-20', postTextSubscription(post)),
                                m(`a.btn.btn-medium.btn-inline.w-button[href="/projects/${post.project_id}/subscriptions/start${post.rewards_that_can_access_post ? `?reward_id=${minimumValueRewardId(post)}` : ''}"]`,
                                    'Acessar esse post'
                                )
                            ] : [
                                m('.fontsize-base.fontweight-semibold.u-marginbottom-20', postTextContribution(post)),
                                m(`a.btn.btn-medium.btn-inline.w-button[href="/projects/${post.project_id}/contributions/new${post.rewards_that_can_access_post ? `?reward_id=${minimumValueRewardId(post)}` : ''}"]`,
                                    'Acessar esse post'
                                )
                            ]

                        ])
                    ] 
                    : 
                    [
                        m('.w-col.w-col-2'),
                        m('.w-col.w-col-8', [
                            m('.post', [
                                m('.u-marginbottom-60 .w-clearfix', [
                                    m('.fontsize-small.fontcolor-secondary.u-text-center', h.momentify(post.created_at)),
                                    m('p.fontweight-semibold.fontsize-larger.u-text-center.u-marginbottom-30', [
                                        m(`a.link-hidden[href="/projects/${post.project_id}/posts/${post.id}#posts"]`, post.title)
                                    ]),
                                    (m('.fontsize-base', m.originalTrust(post.comment_html)))
                                ]),
                                m('.divider.u-marginbottom-60')
                            ])
                        ]),
                        m('.w-col.w-col-2')
                    ]
                ]))),
                m('.w-row', [
                    (!_.isUndefined(attrs.post_id) ? m('.w-col.w-col-2.w-col-push-5',
                                                      m(`a#load-more.btn.btn-medium.btn-terciary[href=\'/projects/${project.project_id}#posts']`, {
                                                         }, 'Ver todos')
                                                       ) :
                        (!list.isLoading() ?
                            (list.collection().length === 0 && attrs.projectContributions().length === 0) ?
                            !project.is_owner_or_admin ? m('.w-col.w-col-10.w-col-push-1',
                                m('p.fontsize-base',
                                    m.trust(
                                        window.I18n.t('empty',
                                            I18nScope({
                                                project_user_name: attrs.userDetails().name,
                                                project_id: project.project_id
                                            })
                                        )
                                    )
                                )
                            ) : '' :
                            m('.w-col.w-col-2.w-col-push-5',
                                (list.isLastPage() ?
                                    list.collection().length === 0 ? 'Nenhuma novidade.' : '' :
                                    m('button#load-more.btn.btn-medium.btn-terciary', {
                                        onclick: list.nextPage
                                    }, 'Carregar mais'))
                            ) :
                            m('.w-col.w-col-2.w-col-push-5', h.loader())
                        ))

                ])
            ]),
        ]);
    }
};

export default projectPosts;
