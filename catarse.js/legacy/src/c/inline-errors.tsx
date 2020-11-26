import m from 'mithril'
import InlineError from './inline-error'

export type InlineErrorsProps = {
    messages: string[]
    className: string
    style: string
}

export class InlineErrors implements m.Component<InlineErrorsProps> {
    view({attrs} : m.Vnode<InlineErrorsProps>) {
        return attrs.messages && attrs.messages.map(message => <InlineError message={message} className={attrs.className} style={attrs.style} />)
    }
}