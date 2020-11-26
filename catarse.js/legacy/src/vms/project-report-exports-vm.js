import m from 'mithril';
import h from '../h';
import { catarse } from '../api';
import models from '../models';

/**
 * @typedef {Object} Report
 * @property {number} project_id
 * @property {string} report_type
 * @property {string} report_type_ext
 * @property {string} state
 * @property {string} created_at
 */

export const createProjectReportExports = async (projectId, report_type, report_type_ext) => {

    return m.request({
        method: 'POST',
        url: `/projects/${projectId}/project_report_exports/`,
        config: h.setCsrfToken,
        data: {
            report_type,
            report_type_ext,
        }
    });
}

export const listProjectReportExports = (projectId) => {
    models.projectReportExports.pageSize(9);
    const projectReportExportsVM = catarse.paginationVM(models.projectReportExports, null, { Prefer: 'count=exact' });
    const vm = h.createBasicPaginationVMWithAutoRedraw(projectReportExportsVM);
    const filter = catarse.filtersVM({
        project_id: 'eq'
    });
    filter.order({
        created_at: 'desc'
    });
    filter.project_id(projectId);
    
    vm.firstPage(filter.parameters());
    return vm;
}