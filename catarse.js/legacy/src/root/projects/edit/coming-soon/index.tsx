import { useEffect, useState, withHooks } from 'mithril-hooks'

import { comingSoonIntegration } from './controllers/coming-soon-integration'
import { deactivateComingSoonLandingPage } from './controllers/deactive-coming-soon-landing-page'
import { activateComingSoonLandingPage } from './controllers/activate-coming-soon-landing-page'
import { ProjectComingSoonSwitch } from './project-coming-soon-switch'
import { ProjectDetails } from '../../../../entities'
import projectVM from '../../../../vms/project-vm'
import { Loader } from '../../../../shared/components/loader'
import PopNotification from '../../../../c/pop-notification'

export type ComingSoonProps = {
    project_id: number
}

export const ComingSoon = withHooks<ComingSoonProps>(_ComingSoon)

function _ComingSoon({project_id}: ComingSoonProps) {

    const [project, setProject] = useState<ProjectDetails>()
    const [isLoading, setIsLoading] = useState(true)
    const comingSoonIntegrationData = comingSoonIntegration(project)

    // Pop notification properties
    const timeDisplayingPopup = 5000
    const [displayPopNotification, setDisplayPopNotification] = useState(false)
    const [popNotificationMessage, setPopNotificationMessage] = useState('')
    const [isPopNotificationError, setIsPopNotificationError] = useState(false)

    const displayPopNotificationMessage = ({message, isError = false} : {message: string, isError?: boolean}) => {
        setPopNotificationMessage(message)
        setDisplayPopNotification(true)
        setIsPopNotificationError(isError)
        setTimeout(() => setDisplayPopNotification(false), timeDisplayingPopup)
    }

    const activate = async () => {
        try {
            setIsLoading(true)
            await activateComingSoonLandingPage(project)
            await loadProject()
            displayPopNotificationMessage({
                message: 'Sua página de pré-lançamento foi publicada com sucesso.'
            })
        } catch (error) {
            console.log('Error activating', error)
            displayPopNotificationMessage({
                message: [
                    'Não foi possível publicar sua página.',
                    'Confira se a Imagem do Projeto e a Frase de Efeito',
                    `estão preenchidas corretamente na aba ${project.mode === 'sub' ? 'Imagens' : 'Card do Projeto'}.`,
                    `Você também pode usar um vídeo, na aba ${project.mode === 'sub' ? 'Descrição' : 'Vídeo'}.`
                ].join(' '),
                isError: true
            })
        } finally {
            setIsLoading(false)
        }
    }

    const deactivate = async () => {
        try {
            setIsLoading(true)
            await deactivateComingSoonLandingPage(project)
            await loadProject()
            displayPopNotificationMessage({
                message: 'Sua página de pré-lançamento foi desativada.'
            })
        } catch (error) {
            console.log('Error deactivating', error)
            displayPopNotificationMessage({
                message: 'Erro ao desativar a página de pré-lançamento.',
                isError: true
            })
        } finally {
            setIsLoading(false)
        }
    }

    const loadProject = async () => {
        try {
            setIsLoading(true)
            const projects = await projectVM.fetchProject(project_id, false)
            setProject(projects[0])
        } catch (error) {
            console.log('Error loading project', error)
        } finally {
            setIsLoading(false)
        }
    }

    useEffect(async () => await loadProject(), [])

    if (isLoading) {
        return (
            <Loader />
        )
    } else {
        return (
            <>
                {
                    displayPopNotification &&
                    <PopNotification
                        message={popNotificationMessage}
                        error={isPopNotificationError} />
                }
                <ProjectComingSoonSwitch
                    comingSoonIntegrationData={comingSoonIntegrationData}
                    project={project} activate={activate} deactivate={deactivate} />
            </>
        )
    }

}
