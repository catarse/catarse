import m from 'mithril';
import { commonPayment } from '../api';
import models from '../models';

const projectSubscriptionsListVM = () => {

    const subscriptions = commonPayment.paginationVM(models.userSubscription, 'last_payment_data_created_at.desc', {
        Prefer: 'count=exact'
    })

    return {
        firstPage: parameters => {
            return new Promise((resolve, reject) => {
                subscriptions
                    .firstPage(parameters)
                    .then(result => {
                        resolve(result);
                        m.redraw();
                    })
                .catch(reject);
            });
        },
        nextPage: () => {
            return subscriptions.nextPage().then(() => m.redraw());
        },
        isLoading: subscriptions.isLoading,
        collection: subscriptions.collection,
        isLastPage: subscriptions.isLastPage,
        total: subscriptions.total,
    };
};

export default projectSubscriptionsListVM;
