import m from 'mithril'
import { withHooks } from 'mithril-hooks'
import InlineError from './inline-error'

export const InlineErrors = withHooks<InlineErrorsProps>(_InlineErrors)

export type InlineErrorsProps = {
    messages?: string[]
    className?: string
    style?: string
}

function _InlineErrors(props : InlineErrorsProps) {
    const { className, messages, style } = props
    return messages && messages.map(message => <InlineError message={message} className={className} style={style} />)
}
