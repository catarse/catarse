import m from 'mithril';
import { catarse } from '../api';
import h from '../h';
import models from '../models';

const { replaceDiacritics } = window;

const context = () => {
    const vm = catarse.filtersVM({
        full_text_index: 'plfts(portuguese)',
        state: 'eq',
        transfer_id: 'eq',
        created_date: 'between',
        transferred_date: 'between',
        amount: 'between'
    });

    const paramToString = p => (p || '').toString().trim();

    vm.state('');
    vm.transfer_id('');

    vm.created_date.lte.toFilter = () => {
        const filter = paramToString(vm.created_date.lte());
        return filter && h.momentFromString(filter).endOf('day').format('');
    };

    vm.created_date.gte.toFilter = () => {
        const filter = paramToString(vm.created_date.gte());
        return filter && h.momentFromString(filter).endOf('day').format('');
    };

    vm.transferred_date.lte.toFilter = () => {
        const filter = paramToString(vm.transferred_date.lte());
        return filter && h.momentFromString(filter).endOf('day').format('');
    };

    vm.transferred_date.gte.toFilter = () => {
        const filter = paramToString(vm.transferred_date.gte());
        return filter && h.momentFromString(filter).endOf('day').format('');
    };

    vm.getAllBalanceTransfers = (filterVM) => {
        models.balanceTransfer.pageSize(false);
        const allTransfers = catarse.loaderWithToken(
            models.balanceTransfer.getPageOptions(filterVM.parameters())
        ).load();
        models.balanceTransfer.pageSize(9);
        return allTransfers;
    };

    return vm;
};
export default context;
