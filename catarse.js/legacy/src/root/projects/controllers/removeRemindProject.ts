import { catarse } from '../../../api'
import { Project } from '../../../entities'
import models from '../../../models'
import projectVM from '../../../vms/project-vm'

export async function removeRemindProject(project: Project) {
    const loaderOpts = models.projectReminder.deleteOptions({ project_id: `eq.${project.project_id}` })
    await catarse.loaderWithToken(loaderOpts).load()
    projectVM.getCurrentProject()
}
