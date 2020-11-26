/**
 * window.c.Tooltip component
 * A component that allows you to show a tooltip on
 * a specified element hover. It receives the element you want
 * to trigger the tooltip and also the text to display as tooltip.
 *
 * Example of use:
 * view: () => {
 *     let tooltip = (el) => {
 *          return m.component(c.Tooltip, {
 *              el: el,
 *              text: 'text to tooltip',
 *              width: 300
 *          })
 *     }
 *
 *     return tooltip('a#link-wth-tooltip[href="#"]');
 *
 * }
 */
import m from 'mithril';
import prop from 'mithril/stream';
import h from '../h';

const tooltip = {
    oninit: function(vnode) {
        let parentHeight = prop(0),
            width = prop(vnode.attrs.width || 280),
            top = prop(0),
            left = prop(0),
            opacity = prop(0),
            parentOffset = prop({ top: 0, left: 0 }),
            tooltip = h.toggleProp(0, 1),
            toggle = () => {
                tooltip.toggle();
                m.redraw();
            };

        const setParentPosition = (localVnode) => {
                parentOffset(h.cumulativeOffset(localVnode.dom));
            },
            setPosition = (localVnode) => {
                const el = localVnode.dom;
                const elTop = el.offsetHeight + el.offsetParent.offsetHeight;
                const style = window.getComputedStyle(el);

                if (window.innerWidth < (el.offsetWidth + 2 * parseFloat(style.paddingLeft) + 30)) { // 30 here is a safe margin
                    el.style.width = window.innerWidth - 30; // Adding the safe margin
                    left(-parentOffset().left + 15); // positioning center of window, considering margin
                } else if ((parentOffset().left + (el.offsetWidth / 2)) <= window.innerWidth && (parentOffset().left - (el.offsetWidth / 2)) >= 0) {
                    left(-el.offsetWidth / 2); // Positioning to the center
                } else if ((parentOffset().left + (el.offsetWidth / 2)) > window.innerWidth) {
                    left(-el.offsetWidth + el.offsetParent.offsetWidth); // Positioning to the left
                } else if ((parentOffset().left - (el.offsetWidth / 2)) < 0) {
                    left(-el.offsetParent.offsetWidth); // Positioning to the right
                }
                top(-elTop); // Setting top position
            };

        vnode.state = {
            width,
            top,
            left,
            opacity,
            tooltip,
            toggle,
            setPosition,
            setParentPosition
        };
    },
    view: function({state, attrs}) {
        const width = state.width();
        return m(attrs.el, {
            onclick: state.toggle,
            oncreate: state.setParentPosition,
            style: { cursor: 'pointer' }
        }, state.tooltip() ? [
            m(`.tooltip.dark[style="width: ${width}px; top: ${state.top()}px; left: ${state.left()}px;"]`, {
                oncreate: state.setPosition
            }, [
                m('.fontsize-smallest', attrs.text)
            ])
        ] : '');
    }
};

export default tooltip;
