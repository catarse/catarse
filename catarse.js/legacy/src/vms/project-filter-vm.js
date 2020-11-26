import m from 'mithril';
import h from '../h';
import { catarse } from '../api';

const { replaceDiacritics } = window;

const vm = catarse.filtersVM({
        full_text_index: 'plfts(portuguese)',
        state: 'eq',
        mode: 'eq',
        recommended: 'eq',
        created_at: 'between',
        project_expires_at: 'between',
        updated_at: 'between',
        goal: 'between',
        progress: 'between',
        category_name: 'eq'
    }),

    paramToString = function (p) {
        return (p || '').toString().trim();
    };

vm.state('online');
vm.mode('');
vm.recommended('');
vm.category_name('');
vm.order({
    project_id: 'desc'
});

vm.updated_at.lte.toFilter = function () {
    const filter = paramToString(vm.updated_at.lte());
    return filter && h.momentFromString(filter).endOf('day').format('');
};

vm.updated_at.gte.toFilter = function () {
    const filter = paramToString(vm.updated_at.gte());
    return filter && h.momentFromString(filter).format();
};

vm.project_expires_at.lte.toFilter = function () {
    const filter = paramToString(vm.project_expires_at.lte());
    return filter && h.momentFromString(filter).endOf('day').format('');
};

vm.project_expires_at.gte.toFilter = function () {
    const filter = paramToString(vm.project_expires_at.gte());
    return filter && h.momentFromString(filter).format();
};

vm.created_at.lte.toFilter = function () {
    const filter = paramToString(vm.created_at.lte());
    return filter && h.momentFromString(filter).endOf('day').format('');
};

vm.created_at.gte.toFilter = function () {
    const filter = paramToString(vm.created_at.gte());
    return filter && h.momentFromString(filter).format();
};

vm.full_text_index.toFilter = function () {
    const filter = paramToString(vm.full_text_index());
    return filter && replaceDiacritics(filter) || undefined;
};

export default vm;
