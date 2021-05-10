import m from 'mithril'
import { useRef, useState, withHooks } from 'mithril-hooks'
import h from '../../h'
import PopNotification from '../../c/pop-notification'

export type ClipboardFieldProps = {
    text: string
    placeholder: string
    popMessage?: string
}

export const ClipboardField = withHooks(_ClipboardField)

function _ClipboardField({text, placeholder, popMessage}: ClipboardFieldProps) {

    const inputFieldRef = useRef(null)
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

    const onClickCopyToClipboard = (event: Event, copyText: HTMLInputElement) => {
        event.preventDefault()
        event.stopPropagation()
        h.copyToClipboard(copyText)
        displayPopNotificationMessage({ message: popMessage || 'Link copiado' })
    }

    return (
        <div class="w-row">
            {
                displayPopNotification &&
                <PopNotification
                    message={popNotificationMessage}
                    error={isPopNotificationError} />
            }
            <div class="w-col w-col-10 w-col-small-10 w-col-tiny-10">
                <input
                oncreate={(vnode: m.VnodeDOM) => inputFieldRef.current = vnode.dom}
                type="text"
                oninput={e => inputFieldRef.current.value = text}
                value={text}
                placeholder={placeholder}
                class="text-field positive w-input" />
            </div>
            <div class="w-col w-col-2 w-col-small-2 w-col-tiny-2">
                <a onclick={e => onClickCopyToClipboard(e, inputFieldRef.current)}
                href="#" class="btn btn-medium btn-terciary fa fa-clipboard btn-no-border w-button"></a>
            </div>
        </div>
    )
}
