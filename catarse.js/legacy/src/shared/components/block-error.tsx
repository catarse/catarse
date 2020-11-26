import { Children } from 'mithril'
import { withHooks } from 'mithril-hooks'

export type BlockErrorProps = {
    className?: string
    style?: string
} & { children?: Children }

export const BlockError = withHooks<BlockErrorProps>(_BlockError)

function _BlockError(props : BlockErrorProps) {

    const {
        className,
        style,
        children,
    } = props

    return (
        <div style={style} class={`${className ? className : ''} fontsize-smaller text-error fa fa-exclamation-triangle`} data-component-name={_BlockError.name}>
            {children}
        </div>
    )
}