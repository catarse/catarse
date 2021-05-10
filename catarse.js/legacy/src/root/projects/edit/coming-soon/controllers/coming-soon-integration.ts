import { ProjectDetails } from '../../../../../entities'
import { ComingSoonIntegration, COMING_SOON_LANDING_PAGE } from './coming-soon.models'

export function comingSoonIntegration(project: ProjectDetails): ComingSoonIntegration {
    return project?.integrations
        .find(integration => integration.name === COMING_SOON_LANDING_PAGE) as ComingSoonIntegration
}
