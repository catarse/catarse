import m from 'mithril';
import { catarse } from '../api';
import _ from 'underscore';
import models from '../models';

const userBalanceTransactionsListVM = userIdParameters => {

    const listVM = catarse.paginationVM(models.balanceTransaction, 'created_at.desc');

    listVM
        .firstPage(userIdParameters)
        .then(() => {
            m.redraw();
        });

    return {
        collection: listVM.collection,
        isLoading: listVM.isLoading,
        isLastPage: listVM.isLastPage,
        nextPage: () => listVM.nextPage().then(() => m.redraw())
    };
};

export default userBalanceTransactionsListVM;