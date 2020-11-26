import m, { Children } from 'mithril'
import { withHooks } from 'mithril-hooks'
import Stream from 'mithril/stream'

export type ModalProps = {
    hideCloseButton?: boolean
    onClose?: () => void
} & { children?: Children }

export const Modal = withHooks<ModalProps>(_Modal)

function _Modal({ hideCloseButton = false, onClose = () => {}, children = null } : ModalProps) {

    const onClickCloseButton = (event : Event) => {
        event.preventDefault()
        onClose()
    }

    const closeButtonClasses = `w-inline-block fa fa-lg modal-close ${hideCloseButton ? '' : 'fa-close'}`
    
    return (
        <div class='modal-backdrop'> 
            <div class='modal-dialog-outer' >
                <div class='modal-dialog-inner modal-dialog-small fontcolor-primary'>
                    <a onclick={onClickCloseButton} href='javascript:void(0);' class={closeButtonClasses}></a>
                    {children}
                </div>
            </div>
        </div>
    )
}