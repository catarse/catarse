import m from 'mithril';

export default class inlineError implements m.Component {
    view({attrs}) {
        const marginbottom = attrs.marginbottom || 'u-marginbottom-20'
        const className = attrs.className
        const style = attrs.style || ''

        if (attrs.message) {
            return (
                <div style={style} class={`${marginbottom} ${className ? className : ''} fontsize-smaller text-error fa fa-exclamation-triangle`}>
                    <span> {attrs.message}</span>
                </div>
            );
        } else {
            return null
        }
    }
}