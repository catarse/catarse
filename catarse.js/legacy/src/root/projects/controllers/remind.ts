import { catarse } from '../../../api';
import { ProjectDetails } from '../../../entities'
import models from '../../../models';
import projectVM from '../../../vms/project-vm';

export async function remind(project: ProjectDetails) {
    const loaderOpts = models.projectReminder.postOptions({ project_id: project.project_id })
    await catarse.loaderWithToken(loaderOpts).load()
    projectVM.getCurrentProject()
}
