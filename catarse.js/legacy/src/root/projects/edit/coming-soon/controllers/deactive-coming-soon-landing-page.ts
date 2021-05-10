import { ProjectDetails } from '../../../../../entities'
import { httpDeleteRequest } from '../../../../../shared/services/infra'
import { comingSoonIntegration } from './coming-soon-integration'

export async function deactivateComingSoonLandingPage(project: ProjectDetails): Promise<void> {
    const comingSoonIntegrationData = comingSoonIntegration(project)
    if (comingSoonIntegrationData?.id) {
        const projectUrl = `/projects/${project.id}/coming-soon/deactivate`
        await httpDeleteRequest(projectUrl, {})
    }
}
