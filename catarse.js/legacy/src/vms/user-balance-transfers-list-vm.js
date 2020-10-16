import m from 'mithril';
import _ from 'underscore';
import models from '../models';
import { catarse } from '../api';


// Defined for UI (balance transfers history is shown in pages of 3 in a row)


const userBalanceTransfersListVM = userIdParameters => {
    
    models.userBalanceTransfers.pageSize(3);

    const loader = catarse.paginationVM(models.userBalanceTransfers, 'requested_in.desc', { Prefer: 'count=exact' });
    
    loader
        .firstPage(userIdParameters)
        .then(() => {
            m.redraw();
        });

    return {
        nextPage : () => loader.nextPage().then(_ => m.redraw()),
        isLoading : loader.isLoading,
        isLastPage : loader.isLastPage,
        collection : loader.collection
    }

};

export default userBalanceTransfersListVM;