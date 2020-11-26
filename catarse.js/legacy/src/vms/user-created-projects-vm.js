import models from '../models';
import prop from 'mithril/stream';
import { catarse } from '../api';
import h from '../h';

const getCreatedProjects = () => {
    models.project.pageSize(9);
    const error = prop(false);
    const createdProjects = catarse.paginationVM(models.project, 'created_at.desc', { Prefer: 'count=exact' });

    return {
        firstPage: params => createdProjects.firstPage(params).then(() => h.redraw()),
        isLoading: createdProjects.isLoading,
        collection: createdProjects.collection,
        isLastPage: createdProjects.isLastPage,
        nextPage: () => createdProjects.nextPage().then(() => h.redraw()),
        collection: createdProjects.collection,
    };
};

export default {
    getCreatedProjects,
};
