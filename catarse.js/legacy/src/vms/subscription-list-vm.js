import h from '../h';
import { commonPayment } from '../api';
import models from '../models';

export default commonPayment.paginationVM(models.userSubscription, 'id.desc', { Prefer: 'count=exact' });

export const getUserPrivateSubscriptionsListVM = userCommonId => {
    models.userSubscription.pageSize(9);
    const subscriptions = commonPayment.paginationVM(models.userSubscription, 'created_at.desc', { Prefer: 'count=exact' });

    return {
        firstPage: params => subscriptions.firstPage(params).then(() => h.redraw()),
        isLoading: subscriptions.isLoading,
        collection: subscriptions.collection,
        isLastPage: subscriptions.isLastPage,
        nextPage: () => subscriptions.nextPage().then(() => h.redraw()),
    };
};
