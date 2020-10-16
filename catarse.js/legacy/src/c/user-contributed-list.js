import m from 'mithril';
import _ from 'underscore';
import h from '../h';
import userContributedBox from '../c/user-contributed-box';
import userSubscriptionBox from '../c/user-subscription-box';
import loadMoreBtn from './load-more-btn';

const I18nScope = _.partial(h.i18nScope, 'users.show.contributions');

const userContributedList = {
    oninit: function(vnode) {
        const title = vnode.attrs.title,
            hideSurveys = vnode.attrs.hideSurveys;
        vnode.state = {
            hideSurveys,
            title
        };
    },
    view: function({state, attrs}) {
        const collection = attrs.collection,
            isSubscription = attrs.isSubscription,
            pagination = attrs.pagination,
            hideSurveys = state.hideSurveys,
            title = state.title;

        return (!_.isEmpty(collection) ? m('div', [m('.section-one-column.u-marginbottom-30',
                m('.w-container', [
                    m('.fontsize-larger.fontweight-semibold.u-marginbottom-30.u-text-center',
                        title
                    ),
                    m('.card.card-secondary.w-hidden-small.w-hidden-tiny.w-row', [
                        m('.w-col.w-col-3',
                            m('.fontsize-small.fontweight-semibold',
                                window.I18n.t('project_col', I18nScope())
                            )
                        ),
                        m('.w-col.w-col-3',
                            m('.fontsize-small.fontweight-semibold',
                                window.I18n.t('contribution_col', I18nScope())
                            )
                        ),
                        m('.w-col.w-col-3',
                            m('.fontsize-small.fontweight-semibold',
                                window.I18n.t('reward_col', I18nScope())
                            )
                        ),
                        m('.w-col.w-col-1'),
                        (!hideSurveys ?
                            m('.w-col.w-col-2',
                                m('.fontsize-small.fontweight-semibold',
                                    (isSubscription ? '' : window.I18n.t('survey_col', I18nScope()))
                                )
                            ) : '')
                    ]),
                    (!isSubscription ?
                        _.map(collection, contribution => m(userContributedBox, {
                            contribution
                        }))
                    :
                        _.map(collection, subscription => m(userSubscriptionBox, {
                            subscription
                        }))
                    ),
                    m('.w-row.u-marginbottom-40.u-margintop-30', [
                        m(loadMoreBtn, {
                            collection: pagination,
                            cssClass: '.w-col-push-4'
                        })
                    ])
                ])),
            m('.divider.u-marginbottom-80.u-margintop-80')
        ]) : m('div', ''));
    }
};

export default userContributedList;
