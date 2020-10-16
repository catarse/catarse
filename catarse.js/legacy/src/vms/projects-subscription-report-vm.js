import m from 'mithril';
import { commonPayment } from '../api';
import models from '../models';

const { replaceDiacritics } = window;

const vm = commonPayment.filtersVM({
        status: 'in',
        search_index: 'plfts(portuguese)',
        reward_external_id: 'eq',
        payment_method: 'eq',
        project_id: 'eq',
        total_paid: 'between',
        paid_count: 'between'
    }),
    paramToString = function (p) {
        return (p || '').toString().trim();
    };

vm.total_paid.gte(0);
vm.total_paid.lte(0);
vm.paid_count.gte(0);
vm.paid_count.lte(0);
vm.status('');
vm.payment_method('');
vm.order({
    created_at: 'desc'
});

vm.search_index.toFilter = function () {
    const filter = paramToString(vm.search_index());
    return filter && replaceDiacritics(filter) || undefined;
};

vm.getAllSubscriptions = (filterVM) => {
    models.userSubscription.pageSize(false);
    const allSubs = commonPayment.loaderWithToken(
      models.userSubscription.getPageOptions(filterVM.parameters())).load();
    models.userSubscription.pageSize(9);
    return allSubs;
};

vm.withNullParameters = () => {
    const withNullVm = commonPayment.filtersVM({
        status: 'in',
        reward_external_id: 'is',
        search_index: 'plfts(portuguese)',
        payment_method: 'eq',
        project_id: 'eq'
    });

    withNullVm.order(vm.order());
    withNullVm.status(vm.status());
    withNullVm.reward_external_id(vm.reward_external_id());
    withNullVm.payment_method(vm.payment_method());
    withNullVm.search_index(vm.search_index());
    withNullVm.project_id(vm.project_id());

    return withNullVm.parameters();
};

export default vm;
