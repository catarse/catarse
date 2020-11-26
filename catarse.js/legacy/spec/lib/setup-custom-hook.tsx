import mq from 'mithril-query'
import { withHooks } from 'mithril-hooks'

export function setupCustomHook<CustomHook extends Function, HookParameters extends any[]>(customHook : CustomHook, ...hookParameters : HookParameters) {
    const returnControl = {}

    mq(
        <CustomHookHooked>
            {props => {
                Object.assign(returnControl, customHook.apply(null, hookParameters))
                return null
            }}
        </CustomHookHooked>
    )

    return returnControl
}

const CustomHookHooked = withHooks(({ children, ...rest }) => {
    return (children[0].children as any as Function)(rest)
})