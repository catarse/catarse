import { ComponentConstructor, useEffect, withHooks } from 'mithril-hooks'
import c from './c'
import h from './h'
import { HeaderMenu } from './root/header-menu'
import { If } from './shared/components/if'
import userVM from './vms/user-vm'

export function AdminWrap(Component : ComponentConstructor<any>, customAttr: { [key:string] : any }) {
    return withHooks<AdminWrapProps>(_AdminWrap, { Component, customAttr })
}

type AdminWrapProps = {
    Component: ComponentConstructor<any>
    customAttr: { [key:string] : any }
};

function _AdminWrap(props : AdminWrapProps) {
    const {
        Component,
        customAttr,
    } = props

    const hideFooter = customAttr.hideFooter
    const Footer = c.root.Footer as any as ComponentConstructor<{}>

    useEffect(() => {
        userVM.getMyUser().then(h.redraw)
    }, [])

    return (
        <div id='app'>
            <HeaderMenu {...customAttr} user={userVM.myUser()}/>
            <Component />
            <If condition={!hideFooter}>
                <Footer />
            </If>
        </div>
    )
}
