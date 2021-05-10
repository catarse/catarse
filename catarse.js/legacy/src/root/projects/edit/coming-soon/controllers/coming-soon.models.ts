import { ProjectIntegration } from '../../../../../entities'

export const COMING_SOON_LANDING_PAGE = 'COMING_SOON_LANDING_PAGE'
type COMING_SOON_LANDING_PAGE = 'COMING_SOON_LANDING_PAGE'

export interface ComingSoonIntegration extends ProjectIntegration {
    id?: number
    name: COMING_SOON_LANDING_PAGE
    data: {
        draft_url: string
    }
}
