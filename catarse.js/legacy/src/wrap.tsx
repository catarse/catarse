import m from 'mithril'
import _ from 'underscore'
import h from './h'
import c from './c'
import userVM from './vms/user-vm'
import { HeaderMenu } from './root/header-menu'
import { If } from './shared/components/if'
import { Loader } from './shared/components/loader'
import { useEffect, useState, withHooks, ComponentConstructor, useRef } from 'mithril-hooks'
import { UserDetails } from './entities'

let app = document.getElementById('application')
let body = document.body

export function Wrap(Component: ComponentConstructor<any>, customAttr: { [key:string] : any }) {
    if (!app) {
        app = document.getElementById('application')
    }
    return withHooks<WrapProps>(_Wrap, { Component, customAttr })
}

type WrapProps = {
    customAttr: { [key:string] : any }
    Component: ComponentConstructor<any>
}

function _Wrap(props : WrapProps) {
    const {
        customAttr,
        Component
    } = props
    const parsedProps = setupWrap(customAttr)

    const [loadingUserDetails, setloadingUserDetails] = useState(true)
    const [loadingMyUserDetails, setLoadingMyUserDetails] = useState(true)

    useEffect(() => {
        if (parsedProps?.user_id) {
            loadUserDetails(parsedProps?.user_id)
            async function loadUserDetails(userId, fromApplicationParameters = true) {
                try {
                    setloadingUserDetails(true)
                    const response = await userVM.fetchUser(userId, fromApplicationParameters)
                    return response || userVM.currentUser();
                } catch(error) {
                    h.captureMessage(`Could not load the user: ${error.message}`)
                } finally {
                    setloadingUserDetails(false)
                }
            }
        } else {
            setloadingUserDetails(false)
        }

        if (userVM.isLoggedIn) {
            loadMyUserDetails()
            async function loadMyUserDetails() {
                try {
                    setLoadingMyUserDetails(true)
                    await userVM.getMyUser()
                } finally {
                    setLoadingMyUserDetails(false)
                }
            }
        } else {
            setLoadingMyUserDetails(false)
        }
    }, [])

    try {
        const headerProps = {...parsedProps, user: userVM.myUser() }
        const Footer = c.root.Footer as any as ComponentConstructor<{}>
        const notHideFooter = !parsedProps?.hideFooter
        const isLoadingRequiredFields = loadingUserDetails || loadingMyUserDetails
        return (
            <div id='app'>
                <If condition={isLoadingRequiredFields}>
                    <Loader />
                </If>
                <If condition={!isLoadingRequiredFields}>
                    <HeaderMenu {...headerProps} />
                    <Component {...parsedProps} />
                    <If condition={notHideFooter} >
                        <Footer {...parsedProps} />
                    </If>
                </If>
            </div>
        )
    } catch(e) {
        console.log('Error on wrap.view:', e.stack);
        return (
            <div id='app' />
        )
    }
}

declare var CatarseAnalytics : {
    pageView(param : boolean): void
    origin(): void
}

let firstRun = true

function setupWrap(customAttr: { [key:string] : any }) {
    try {
        if (firstRun) {
            firstRun = false
        } else {
            try {
                CatarseAnalytics.pageView(false)
                CatarseAnalytics.origin()
            } catch (e) {
                console.error(e)
            }
        }

        const parameters = app.getAttribute('data-parameters') ? JSON.parse(app.getAttribute('data-parameters')) : {};
        let attr = customAttr
        let postParam = m.route.param('post_id') || parameters.post_id
        let projectParam = m.route.param('project_id') || parameters.project_id
        let projectUserIdParam = m.route.param('project_user_id') || parameters.user_id || parameters.project_user_id
        let userParam = m.route.param('user_id') || app.getAttribute('data-userid') || parameters.user_id || customAttr?.user_id || h.getUserID()
        let rewardIdParam = m.route.param('reward_id')
        let surveyIdParam = m.route.param('survey_id')
        let thankYouParam = app && JSON.parse(app.getAttribute('data-contribution'))

        const addToAttr = function (newAttr) {
            attr = _.extend({}, newAttr, attr)
        }

        if (postParam) {
            addToAttr({ post_id: postParam })
        }

        if (projectParam) {
            addToAttr({ project_id: projectParam })
        }

        if (userParam) {
            addToAttr({ user_id: parseInt(userParam, 10) })
        }

        if (projectUserIdParam) {
            addToAttr({ project_user_id: projectUserIdParam })
        }

        if (surveyIdParam) {
            addToAttr({ survey_id: surveyIdParam })
        }

        if (rewardIdParam) {
            addToAttr({ reward_id: rewardIdParam })
        }

        if (thankYouParam) {
            addToAttr({ contribution: thankYouParam })
        }

        if (window.localStorage && window.localStorage.getItem('globalVideoLanding') !== 'true') {
            addToAttr({ withAlert: false })
        }

        if (document.getElementById('fixed-alert')) {
            addToAttr({ withFixedAlert: true })
        }

        body.className = 'body-project closed'
        return attr
    } catch(e) {
        console.log('Error on wrap.oninit:', e)
        return {}
    }
}
