import m from 'mithril';
import {
    commonPayment
} from '../api';
import h from '../h';

const { replaceDiacritics } = window;

const vm = commonPayment.filtersVM({
        status: 'eq',
        search_index: 'plfts(portuguese)',
        payment_method: 'eq'
    }),

    paramToString = function (p) {
        return (p || '').toString().trim();
    };

// Set default values
vm.status('');
vm.payment_method('');
vm.order({
    id: 'desc'
});

vm.search_index.toFilter = function () {
    const filter = paramToString(vm.search_index());
    return filter && replaceDiacritics(filter) || undefined;
};

export default vm;
