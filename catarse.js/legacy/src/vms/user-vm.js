import m from 'mithril';
import prop from 'mithril/stream';
import _ from 'underscore';
import { catarse, commonPayment } from '../api';
import h from '../h';
import models from '../models';
import projectFilters from './project-filters-vm';

const idVM = h.idVM,
    currentUser = prop({}),
    createdVM = catarse.filtersVM({ project_user_id: 'eq' });

const getUserCreatedProjects = (user_id, pageSize = 3) => {
    createdVM.project_user_id(user_id).order({ project_id: 'desc' });

    models.project.pageSize(pageSize);

    const lUserCreated = catarse.loaderWithToken(models.project.getPageOptions(createdVM.parameters()));

    return lUserCreated.load();
};

const getPublicUserContributedProjects = (user_id, pageSize = 3) => {
    const contextVM = catarse.filtersVM({
        user_id: 'eq',
    });

    contextVM.user_id(user_id);

    models.contributor.pageSize(pageSize);

    const lUserContributed = catarse.loaderWithToken(models.contributor.getPageOptions(contextVM.parameters()));

    return lUserContributed.load();
};

const getUserBalance = user_id => {
    const contextVM = catarse.filtersVM({
        user_id: 'eq',
    });
    contextVM.user_id(user_id);

    const loader = catarse.loaderWithToken(models.balance.getPageOptions(contextVM.parameters()));
    return loader.load();
};

const getUserBankAccount = user_id => {
    const contextVM = catarse.filtersVM({
        user_id: 'eq',
    });

    contextVM.user_id(user_id);

    const lUserAccount = catarse.loaderWithToken(models.bankAccount.getPageOptions(contextVM.parameters()));
    return lUserAccount.load();
};

const getUserProjectReminders = user_id => {
    const contextVM = catarse.filtersVM({
        user_id: 'eq',
        without_notification: 'eq',
    });

    contextVM.user_id(user_id).without_notification(true);

    models.projectReminder;

    const lUserReminders = catarse.loaderWithToken(models.projectReminder.getPageOptions(contextVM.parameters()));

    return lUserReminders.load();
};

const getUserUnsubscribesProjects = user_id => {
    const contextVM = catarse.filtersVM({
        user_id: 'eq',
    });

    contextVM.user_id(user_id);

    models.unsubscribes;

    const lUserReminders = catarse.loaderWithToken(models.unsubscribes.getPageOptions(contextVM.parameters()));

    return lUserReminders.load();
};

const getMailMarketingLists = () => {
    const l = catarse.loaderWithToken(models.mailMarketingList.getPageOptions({ order: 'id.asc' }));

    return l.load();
};

const getUserCreditCards = user_id => {
    const contextVM = catarse.filtersVM({
        user_id: 'eq',
    });

    contextVM.user_id(user_id);

    models.userCreditCard.pageSize(false);

    const lUserCards = catarse.loaderWithToken(models.userCreditCard.getPageOptions(contextVM.parameters()));

    return lUserCards.load();
};

const toggleDelivery = (projectId, contribution) =>
    m.request({
        method: 'GET',
        config: h.setCsrfToken,
        url: `/projects/${projectId}/contributions/${contribution.contribution_id}/toggle_delivery`,
    });

const toggleAnonymous = (projectId, contribution) =>
    m.request({
        method: 'GET',
        config: h.setCsrfToken,
        url: `/projects/${projectId}/contributions/${contribution.contribution_id}/toggle_anonymous`,
    });

const getUserContributedProjects = (user_id, pageSize = 3) => {
    const contextVM = catarse.filtersVM({
        user_id: 'eq',
        state: 'in',
    });

    contextVM
        .user_id(user_id)
        .order({
            created_at: 'desc',
        })
        .state(['refunded', 'pending_refund', 'paid']);

    models.userContribution.pageSize(pageSize);

    const lUserContributed = catarse.loaderWithToken(models.userContribution.getPageOptions(contextVM.parameters()));

    return lUserContributed.load();
};

const getUserSubscribedProjects = (user_external_id, pageSize = 3) => {
    const contextVM = commonPayment.filtersVM({
        user_external_id: 'eq',
        status: 'in',
    });

    contextVM
        .user_external_id(user_external_id)
        .order({
            created_at: 'desc',
        })
        .status(['started', 'active', 'canceling']);

    models.userSubscription.pageSize(pageSize);

    const loaderUserSubscribed = commonPayment.loaderWithToken(models.userSubscription.getPageOptions(contextVM.parameters()));

    return loaderUserSubscribed.load();
};

const fetchUser = (user_id, handlePromise = true, customProp = currentUser) => {
    idVM.id(user_id);

    const lUser = catarse.loaderWithToken(models.userDetail.getRowOptions(idVM.parameters()));

    if (!handlePromise) {
        return lUser.load();
    } else {
        customProp(currentUser()); // first load user from cache
        lUser
            .load()
            .then(
                _.compose(
                    customProp,
                    _.first
                )
            )
            .then(_ => h.redraw());
        return customProp;
    }
};

const getCurrentUser = () => {
    fetchUser(h.getUserID());
    return currentUser;
};

const displayName = user => {
    const u = user || { name: 'no name' };
    return _.isEmpty(u.public_name) ? u.name : u.public_name;
};

const displayImage = user => {
    const defaultImg = 'https://catarse.me/assets/catarse_bootstrap/user.jpg';

    if (user) {
        return user.profile_img_thumbnail || defaultImg;
    }

    return defaultImg;
};

const displayCover = user => {
    if (user) {
        return user.profile_cover_image || displayImage(user); //
    }

    return displayImage(user);
};

const getUserRecommendedProjects = contribution => {
    const sample3 = _.partial(_.sample, _, 3),
        loaders = prop([]),
        collection = prop([]),
        { user_id } = h.getUser();

    const loader = () =>
        _.reduce(
            loaders(),
            (memo, curr) => {
                const _memo = _.isFunction(memo) ? memo() : memo,
                    _curr = _.isFunction(curr) ? curr() : curr;

                return _memo && _curr;
            },
            true
        );

    const loadPopular = () => {
        const filters = projectFilters().filters;
        const popular = catarse.loaderWithToken(models.project.getPageOptions(_.extend({}, { order: 'score.desc' }, filters.score.filter.parameters())));

        loaders().push(popular);

        popular
            .load()
            .then(
                _.compose(
                    collection,
                    sample3
                )
            )
            .then(() => m.redraw());
    };

    const pushProject = ({ project_id }) => {
        const project = catarse.loaderWithToken(
            models.project.getPageOptions(
                catarse
                    .filtersVM({ project_id: 'eq' })
                    .project_id(project_id)
                    .parameters()
            )
        );

        loaders().push(project);
        project.load().then(data => {
            collection().push(_.first(data));
            m.redraw();
        });
    };

    const projects = catarse.loaderWithToken(
        models.recommendedProjects.getPageOptions(
            catarse
                .filtersVM({ user_id: 'eq' })
                .user_id(user_id)
                .parameters()
        )
    );

    projects.load().then(recommended => {
        if (recommended.length > 0) {
            _.map(recommended, pushProject);
        } else {
            loadPopular();
        }
        m.redraw();
    });

    return {
        loader,
        collection,
    };
};

const userVM = {
    getUserCreatedProjects,
    getUserCreditCards,
    toggleDelivery,
    toggleAnonymous,
    getUserProjectReminders,
    getUserRecommendedProjects,
    getUserContributedProjects,
    getUserSubscribedProjects,
    getUserBalance,
    getUserBankAccount,
    getPublicUserContributedProjects,
    displayImage,
    displayCover,
    displayName,
    fetchUser,
    getCurrentUser,
    currentUser,
    getMailMarketingLists,
    getUserUnsubscribesProjects,
    get isLoggedIn() {
        return h.getUserID() !== null;
    },
};

export default userVM;
