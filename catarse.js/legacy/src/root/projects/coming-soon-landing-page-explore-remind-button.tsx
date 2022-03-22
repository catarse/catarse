import { useEffect, useCallback, useRef, useState, withHooks } from 'mithril-hooks'
import { Project } from '../../entities'
import { Loader } from '../../shared/components/loader'
import PopNotification from '../../c/pop-notification'
import h from '../../h'
import { getCurrentUserCached } from '../../shared/services/user/get-current-user-cached'
import { isLoggedIn } from '../../shared/services/user/is-logged-in'
import m from 'mithril'
import _ from 'underscore';
import { removeRemindProject } from './controllers/removeRemindProject'
import { remindProject } from './controllers/remindProject'
import './coming-soon-landing-page-bookmark-card.scss'
import './coming-soon-landing-page-explore-remind-button.scss'
import { catarse } from '../../api'
import models from '../../models';

export type ComingSoonLandingPageExploreRemindButtonProps = {
    project: Project
    isFollowing: boolean
}

export const ComingSoonLandingPageExploreRemindButton = withHooks<ComingSoonLandingPageExploreRemindButtonProps>(_ComingSoonLandingPageExploreRemindButton)

function _ComingSoonLandingPageExploreRemindButton(props: ComingSoonLandingPageExploreRemindButtonProps) {

    const { project, isFollowing } = props
    const popupTimeout = useRef<NodeJS.Timeout>()
    const [isLoading, setIsLoading] = useState(false)
    const [currentUserBookmarked, setCurrentUserBookmarked] = useState(isFollowing)

    // Pop notification properties
    const timeDisplayingPopup = 6000
    const [displayPopNotification, setDisplayPopNotification] = useState(false)
    const [popNotificationMessage, setPopNotificationMessage] = useState('')
    const [isPopNotificationError, setIsPopNotificationError] = useState(false)

    useEffect(() => {
        setCurrentUserBookmarked(project.in_reminder)
    }, [project.in_reminder])

    useEffect(() => {
        displayPop()
    }, [])

    function displayPop() {
        const displayPop = localStorage.getItem('display_pop');
        const setBookmarked = localStorage.getItem('set_bookmarked');

        if (displayPop) {
            if (displayPop == 'success') {
                displayPopNotificationMessage({ message: 'Você irá receber um email quando este projeto for publicado!' })
            } else if (displayPop == 'error') {
                displayPopNotificationMessage({ message: 'Error ao salvar lembrete.', isError: true })
            }

            localStorage.removeItem('display_pop');
        }

        if (setBookmarked && parseInt(setBookmarked) == project.project_id) {
            setCurrentUserBookmarked(true)
            localStorage.removeItem('set_bookmarked');
        }

        h.redraw();
    }

    function redirectToLogin() {
        if (!isLoggedIn(getCurrentUserCached())) {
            h.storeAction('reminder', project.project_id)
            h.navigateToDevise(`?redirect_to=/explore?filter=coming_soon_landing_page`)
            return true
        }

        return false
    }

    const handleRemindMe = useCallback(() => {
        if (redirectToLogin()) return
        toggleRemindMeProject(true);
    }, [])

    const handleRemoveRemindMe = useCallback(() => {
        toggleRemindMeProject(false)
    }, [])

    async function toggleRemindMeProject(isRemind: boolean) {
        try {
            setIsLoading(true)
            await isRemind ? remindProject(project) : removeRemindProject(project)
            setCurrentUserBookmarked(isRemind)
            await displayPopNotificationMessage({ message: successMessage(project) })
        } catch (error) {
            await displayPopNotificationMessage({ message: errorMessage(project), isError: true })
        } finally {
            setIsLoading(false)
        }
    }

    const successMessage = (project) => {
        return project.in_reminder ?
            'Ok, Removemos o lembrete por e-mail de quando a campanha for ao ar!' :
            'Você irá receber um email quando este projeto for publicado!'

    };
    const errorMessage = (project) => {
        return project.in_reminder ?
            'Error ao remover lembrete.' :
            'Error ao salvar lembrete.'
    };

    async function displayPopNotificationMessage({message, isError = false} : {message: string, isError?: boolean}) {
        setPopNotificationMessage(message)
        setIsPopNotificationError(isError)
        setDisplayPopNotification(!displayPopNotification)
        if (popupTimeout.current) clearTimeout(popupTimeout.current)
        setTimeout(() => setDisplayPopNotification(true))
        popupTimeout.current = setTimeout(() => setDisplayPopNotification(false), timeDisplayingPopup)
    }

    return (
        <div class='save-project-card-wrapper'>
            {
                displayPopNotification &&
                <PopNotification
                    message={popNotificationMessage}
                    error={isPopNotificationError} />
            }
            <div class="back-project--btn-row">
                {
                    isLoading ?
                        <Loader />
                        :
                        currentUserBookmarked ?
                            <button onclick={handleRemoveRemindMe} class='btn btn-medium btn-terciary w-button'>
                                <span class="fa fa-bookmark text-success"></span>&nbsp;
                                Projeto Salvo
                            </button>
                            :
                            <button onclick={handleRemindMe} class='btn btn-medium btn-dark w-button'>
                                <span class="fa fa-bookmark-o"></span>&nbsp;
                                Avise-me do lançamento!
                            </button>
                }
            </div>
        </div>
    )
}
