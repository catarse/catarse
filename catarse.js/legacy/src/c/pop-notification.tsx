import m from 'mithril';
import h from '../h';

export type PopNotificationAttrs = {
    error: boolean
    message: string
    toggleOpt(newData? : boolean): boolean
}

type PopNotificationState = {
    displayNotification(newData? : boolean): boolean
    setPopTimeout(): void
}

export default class PopNotification  {

    oninit(vnode : m.Vnode<PopNotificationAttrs, PopNotificationState>) {
        const displayNotification = vnode.attrs.toggleOpt || h.toggleProp(true, false),
            setPopTimeout = () => {
                setTimeout(() => { displayNotification(false); m.redraw(); }, 3000);
            };
        vnode.state = {
            displayNotification,
            setPopTimeout
        };
    }

    view({ state, attrs } : m.Vnode<PopNotificationAttrs, PopNotificationState>) {

        if (state.displayNotification()) {
            return (
                <div oncreate={state.setPopTimeout} class={`flash w-clearfix card card-notification u-radius zindex-20 ${attrs.error ? 'card-error' : ''}`}>
                    <img onclick={() => state.displayNotification(false)} class='icon-close' src='/assets/catarse_bootstrap/x.png' width='12' alt='fechar'/>
                    <div class='fontsize-small'>
                        {m.trust(attrs.message)}
                    </div>
                </div>
            )
        } else {
            return <span />
        }
    }
}