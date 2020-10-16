import m from 'mithril';
import _ from 'underscore';
import h from '../h';
import projectCard from './project-card';

const projectRowWithHeader = {
    view: function ({ attrs }) {
        const collection = attrs.collection,
            title = attrs.title || collection.title,
            ref = attrs.ref,
            showFriends = attrs.showFriends,
            wrapper = attrs.wrapper || `.section.u-marginbottom-40${attrs.isOdd ? '.bg-gray' : ''}`,
            showFriendsLinkComponent = (
                showFriends ?
                    m(`a.btn.btn-small.btn-terciary.btn-inline.u-right-big-only.btn-no-border[href="/connect-facebook?ref=${ref}"]`,
                        'Encontrar amigos') : ''
            ),
            collectionHeaderComponent = (
                (!_.isUndefined(collection.title) || !_.isUndefined(collection.hash)) ?
                    m('.u-marginbottom-20.u-text-center-small-only', [
                        m('div', _.map(collection.badges, badge => m(`img[src="/assets/catarse_bootstrap/${badge}.png"][width='105']`))),
                        m('.w-row', [
                            m('.w-col.w-col-8', m('.fontsize-larger.u-marginbottom-20', `${title}`)),
                            m('.w-col.w-col-4', [
                                m(`a.btn.btn-small.btn-terciary.btn-inline.u-right-big-only[href="/explore?ref=${ref}&${m.buildQueryString(collection.query)}"]`,
                                    {
                                        oncreate: m.route.link
                                    },
                                    'Ver todos'
                                ),
                                showFriendsLinkComponent
                            ])
                        ])
                    ]) : ''
            ),
            projectsOrLoadingIconComponent = (
                collection.loader() ?
                    h.loader() :
                    m('.w-row',
                        _.map(collection.collection(), project => m(projectCard, {
                            project,
                            ref,
                            showFriends
                        }))
                    )
            );

        const conditionToShowProjectCards = collection.loader() || (collection.collection().length > 0);

        if (conditionToShowProjectCards) {
            return m(wrapper, [
                m('.w-container', [
                    collectionHeaderComponent,
                    projectsOrLoadingIconComponent
                ])
            ]);
        }
        return m('div');
    }
};

export default projectRowWithHeader;
