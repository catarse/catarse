import m from 'mithril';
import h from '../h';
import { getCurrentUserCached } from '../shared/services/user/get-current-user-cached';
import { isLoggedIn } from '../shared/services/user/is-logged-in';
import { withHooks } from 'mithril-hooks'

export default withHooks<ConnectFacebookProps>(ConnectFacebook)

type ConnectFacebookProps = {
    linkClass: string
    label: string
    buttonClass: string
    styleInput?: string
}

function ConnectFacebook({ label, linkClass, buttonClass, styleInput } : ConnectFacebookProps) {
    const currentUser = getCurrentUserCached();
    const hasFBAuth = isLoggedIn(currentUser) && currentUser.has_fb_auth;

    return (
        hasFBAuth ?
        m(`${linkClass}[href="/connect-facebook"]`, label) :
        m('form.button_to', {
            action: '/users/auth/facebook',
            method: 'POST',
        }, [
            m(`${buttonClass}[type="submit"][value="${label}"][style="${styleInput}"]`),
            m(`input[name='authenticity_token'][type='hidden'][value='${h.authenticityToken()}']`),
        ])
    )
}
