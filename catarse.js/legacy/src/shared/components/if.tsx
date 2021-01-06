import m from 'mithril'
import { withHooks } from 'mithril-hooks'

export const If = withHooks<IfProps>(_If)

type IfProps = {
    condition: boolean
    children?: m.ChildArrayOrPrimitive
}

function _If({ condition, children } : IfProps) {
    return (condition && children)
}
