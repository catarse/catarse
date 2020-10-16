import m from 'mithril';
import { catarse } from '../api';
import h from '../h';
import models from '../models';

const { replaceDiacritics } = window;

const vm = catarse.filtersVM({
        full_text_index: 'plfts(portuguese)',
        state: 'in',
        reward_id: 'eq',
        delivery_status: 'eq',
        survey_status: 'in',
        project_id: 'eq'
    }),
    paramToString = p => (p || '').toString().trim();

vm.state('');
vm.order({
    id: 'desc'
});

vm.full_text_index.toFilter = () => {
    const filter = paramToString(vm.full_text_index());
    return filter && replaceDiacritics(filter) || undefined;
};

vm.getAllContributions = (filterVM) => {
    models.projectContribution.pageSize(false);
    const allContributions = catarse.loaderWithToken(
      models.projectContribution.getPageOptions(filterVM.parameters())).load();
    models.projectContribution.pageSize(9);
    return allContributions;
};

vm.updateStatus = data => m.request({
    method: 'PUT',
    url: `/projects/${vm.project_id()}/contributions/update_status.json`,
    data,
    config: h.setCsrfToken
});

vm.withNullParameters = () => {
    const withNullVm = catarse.filtersVM({
        full_text_index: 'plfts(portuguese)',
        state: 'in',
        reward_id: 'is',
        delivery_status: 'eq',
        project_id: 'eq'
    });

    withNullVm.full_text_index(vm.full_text_index());
    withNullVm.order(vm.order());
    withNullVm.state(vm.state());
    withNullVm.reward_id(vm.reward_id());
    withNullVm.delivery_status(vm.delivery_status());
    withNullVm.project_id(vm.project_id());

    return withNullVm.parameters();
};

export default vm;
