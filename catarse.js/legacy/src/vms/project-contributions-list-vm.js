import m from 'mithril';
import { catarse } from '../api';
import models from '../models';

const projectContributionsListVM = () => {
    const listVM = catarse.paginationVM(models.projectContribution, 'id.desc', {
        Prefer: 'count=exact',
    });

    return {
        firstPage: parameters => {
            return listVM.firstPage(parameters).then(() => m.redraw());
        },
        nextPage: () => {
            return listVM.nextPage().then(() => m.redraw());
        },
        isLoading: listVM.isLoading,
        collection: listVM.collection,
        isLastPage: listVM.isLastPage,
        total: listVM.total,
    };
};

export default projectContributionsListVM;
