import { ProjectDetails } from '../../../../../entities'
import { httpPutRequest } from '../../../../../shared/services/infra'
import { comingSoonIntegration } from './coming-soon-integration'
import { ComingSoonIntegration, COMING_SOON_LANDING_PAGE } from './coming-soon.models'

export async function defineLandingPageUrl(project: ProjectDetails, url: string) {
    const comingSoonIntegrationData = comingSoonIntegration(project)
    if (comingSoonIntegrationData?.id) {
        const projectUrl = `/projects/${project.id}/integrations/${comingSoonIntegrationData.id}.json`
        const integrationData: ComingSoonIntegration = {
            name: COMING_SOON_LANDING_PAGE,
            data: { url }
        }
        const response = await httpPutRequest(projectUrl, {}, integrationData)
        integrationData.id = response.data['integration_id']
        project.integrations.push(integrationData)
    }
}
