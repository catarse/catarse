import { ProjectDetails } from '../../../../../entities'
import { httpPostRequest } from '../../../../../shared/services/infra'
import railsErrorsVM from '../../../../../vms/rails-errors-vm'
import { ComingSoonIntegration } from './coming-soon.models'

export async function activateComingSoonLandingPage(project: ProjectDetails): Promise<void> {
    const activateUrl = `/projects/${project.id}/coming-soon/activate`
    try {
        const response = await httpPostRequest<ComingSoonIntegration>(activateUrl, {}, null)
        project.integrations.push(response.data)
    } catch (error) {
        railsErrorsVM.setRailsErrors(error?.data)
        throw error
    }
}
