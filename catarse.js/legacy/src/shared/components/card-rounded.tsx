import { Children } from 'mithril'
import { withHooks } from 'mithril-hooks'

export type CardRoundedProps = {
    className?: string
    style?: string
} & { children?: Children }

export const CardRounded = withHooks<CardRoundedProps>(_CardRounded)

function _CardRounded({className, style, children} : CardRoundedProps) {
    return (
        <div style={style} class={`card u-radius ${className ? className : ''}`}>
            {children}
        </div>
    )
}