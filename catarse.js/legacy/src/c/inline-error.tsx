import m from 'mithril';

export default class inlineError implements m.Component {
    view({attrs}) {
        const marginbottom = attrs.marginbottom || 'u-marginbottom-20'
        if (attrs.message) {
            return (
                <div class={`${marginbottom} fontsize-smaller text-error fa fa-exclamation-triangle`}>
                    <span> {attrs.message}</span>
                </div>
            );
        } else {
            return null
        }
    }
}