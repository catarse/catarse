import m from 'mithril';
import h from '../h';
import models from '../models';
import { catarse, commonProject } from '../api';

models.adminProject.pageSize(9);
export default catarse.paginationVM(models.adminProject, 'pledged.desc', { Prefer: 'count=exact' });


const getProjectSubscribersListVM = () => {
    models.projectSubscriber.pageSize(15);
    const projectSubscribersListVM = commonProject.paginationVM(models.projectSubscriber, null, { Prefer: 'count=exact' });
    return h.createBasicPaginationVMWithAutoRedraw(projectSubscribersListVM);
};

const getProjectContributorsListVM = () => {
    models.contributor.pageSize(15);
    const projectContributorsListVM = catarse.paginationVM(models.contributor, null, { Prefer: 'count=exact' });
    return h.createBasicPaginationVMWithAutoRedraw(projectContributorsListVM);
}

export {
    getProjectSubscribersListVM,
    getProjectContributorsListVM
};