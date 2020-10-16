import m from 'mithril'
import InlineError from './inline-error'

export class InlineErrors {
    view({attrs} : m.Vnode<{ messages : string[] }>) {
        return attrs.messages && attrs.messages.map(message => <InlineError message={message} />)
    }
}