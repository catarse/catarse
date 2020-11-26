import {
    commonPayment,
    commonProxy,
    commonAnalytics
} from '../api';
import m from 'mithril';
import h from '../h';
import _ from 'underscore';
import models from '../models';
import moment from 'moment';

const getSubscriptionTransitions = (projectId, toStatus, fromStatus, startAt, endAt) => {
    const vm = commonPayment.filtersVM({
        project_id: 'eq',
        created_at: 'between',
        from_status: 'in',
        to_status: 'in'
    });

    vm.created_at.gte(startAt);
    vm.created_at.lte(endAt);
    vm.project_id(projectId);
    vm.from_status(fromStatus);
    vm.to_status(toStatus);

    const lSub = commonPayment.loaderWithToken(models.subscriptionTransition.getPageOptions(vm.parameters()));
    return lSub.load();
};

const getNewSubscriptions = (projectId, startAt, endAt) => {
    const vm = commonPayment.filtersVM({
        project_id: 'eq',
        created_at: 'between',
        status: 'in'
    });

    vm.created_at.gte(startAt);
    vm.created_at.lte(endAt);
    vm.project_id(projectId);
    vm.status('active');

    const lSub = commonPayment.loaderWithToken(models.userSubscription.getPageOptions(vm.parameters()));
    return lSub.load();
};

const getSubscriptionsPerMonth = (projectId) => {
    const vm = commonPayment.filtersVM({
        project_id: 'eq'
    }).order({
        month: 'desc',
        payment_method: 'desc'
    });

    models.subscriptionsPerMonth.pageSize(false);
    vm.project_id(projectId);
    const lSub = commonPayment.loaderWithToken(models.subscriptionsPerMonth.getPageOptions(vm.parameters()));
    return lSub.load();
};

const getUserProjectSubscriptions = (userId, projectId, status) => {
    const vm = commonPayment.filtersVM({
        user_id: 'eq',
        project_id: 'eq',
        created_at: 'between',
        status: 'in'
    });

    vm.user_id(userId);
    vm.project_id(projectId);
    vm.status(status);
    const lSub = commonPayment.loaderWithToken(models.userSubscription.getPageOptions(vm.parameters()));
    return lSub.load();
};

const getSubscription = (subscriptionId) => {
    const vm = commonPayment.filtersVM({
        id: 'eq'
    });
    vm.id(subscriptionId);

    const lSub = commonPayment.loaderWithToken(models.userSubscription.getRowOptions(vm.parameters()));

    return lSub.load();
};

const toogleAnonymous = (subscription) => {
    const subscriptionAnonymity = {
        set_anonymity_state: !subscription.checkout_data.anonymous
    }

    const setAnonymityModel = models.setSubscriptionAnonymity(subscription.id)
    subscription.checkout_data.anonymous = !subscription.checkout_data.anonymous;
    m.redraw();

    return commonProxy
        .loaderWithToken(setAnonymityModel.postOptions(subscriptionAnonymity, {}))
        .load()
        .then(d => {
            if ('set_subscription_anonymity' in d) {
                subscription.checkout_data.anonymous = d.set_subscription_anonymity.anonymous;
                m.redraw();
            }
            return d;
        })
        .catch(err => {
            subscription.checkout_data.anonymous = !subscription.checkout_data.anonymous;
            m.redraw();
        });
};

const getNewSubscriptionsInsightsFromPeriod = (project_id, startDate, endDate) => {

    const start_date = h.momentify(startDate, 'YYYY-MM-DDTHH:mm:ssZ');
    const end_date = h.momentify(endDate, 'YYYY-MM-DDTHH:mm:ssZ');

    return commonAnalytics
        .loaderWithToken(models.newSubscribersFromPeriod.getRowOptions({project_id, start_date, end_date}))
        .load()
        .then(insightData => {
            h.redraw();
            return insightData;
        })
        .catch(error => {
            console.log('Error getting insights resume:', error);
            h.redraw();
        })
};

const getNewSubscriptionsInsightsFromLastWeek = project_id => {
    const today = moment();
    const todayMinus7Days = moment().subtract(7, 'days');
    return getNewSubscriptionsInsightsFromPeriod(project_id, todayMinus7Days, today);
};

const getNewSubscriptionsInsightsFromLast2Week = project_id => {
    const todayMinus7Days = moment().subtract(7, 'days');
    const todayMinus14Days = moment().subtract(14, 'days');
    return getNewSubscriptionsInsightsFromPeriod(project_id, todayMinus14Days, todayMinus7Days);
};

const subscriptionVM = {
    getNewSubscriptions,
    getSubscriptionsPerMonth,
    getSubscriptionTransitions,
    getUserProjectSubscriptions,
    getSubscription,
    toogleAnonymous,
    getNewSubscriptionsInsightsFromPeriod,
    getNewSubscriptionsInsightsFromLastWeek,
    getNewSubscriptionsInsightsFromLast2Week
};

export default subscriptionVM;
