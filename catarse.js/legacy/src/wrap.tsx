/** global CatarseAnalytics */
import m from 'mithril'
import _ from 'underscore'
import h from './h'
import c from './c'
import userVM from './vms/user-vm'

let app = document.getElementById('application')
let body = document.body

export function Wrap(Component, customAttr) {
    if (!app) {
        app = document.getElementById('application')
    }

    let firstRun = true
    let loadingUserDetails = false
    
    function loadUserDetails(userId) {
        loadingUserDetails = true
        userVM
            .fetchUser(userId, false)
            .then(() => loadingUserDetails = false)
            .catch(error => {
                loadingUserDetails = false
                h.captureMessage(`Could not load the user: ${error.message}`)
            })
    }

    return {
        oninit(vnode) {

            try {
                vnode.state.attr = {}
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
                let userParam = m.route.param('user_id') || app.getAttribute('data-userid') || parameters.user_id || customAttr?.user_id
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
                    addToAttr({ user_id: userParam })
                    loadUserDetails(userParam)
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
    
                vnode.state.attr = attr
            } catch(e) {
                console.log('Error on wrap.oninit:', e)
            }
        },
        oncreate(vnode) {
            const hasUnmanagedRootComponent = app && 
                app.children.app &&
                app.children.length > 1

            const removeUnmanagedRootComponentFromDom = () => {
                app.removeChild(app.children.app)
            }

            if (hasUnmanagedRootComponent) {
                removeUnmanagedRootComponentFromDom()
            }
        },
        view({ state: { attr } }) {
            
            try {

                const Menu = c.root.Menu
                const Footer = c.root.Footer
                const notHideFooter = !attr?.hideFooter
                return (
                    <div id='app'>
                        <Menu {...attr} />
                        {
                            loadingUserDetails ?
                                h.loader()
                                :
                                <Component {...attr} />
                        }
                        {notHideFooter && <Footer {...attr} />}
                    </div>
                )
            } catch(e) {
                console.log('Error on wrap.view:', e.stack);
                return (
                    <div id='app' />
                )
            }
        }
    }
}