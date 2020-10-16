/**
 * window.c.landingSignup component
 * A visual component that displays signup email typically used on landing pages.
 * It accepts a custom form action to attach to third-party services like Mailchimp
 *
 * Example:
 * view: () => {
 *      ...
 *      m.component(c.landingSignup, {
 *          builder: {
 *              customAction: 'http://formendpoint.com'
 *          }
 *      })
 *      ...
 *  }
 */
import m from 'mithril';
import prop from 'mithril/stream';
import h from '../h';

const landingSignup = {
    oninit: function(vnode) {
        const builder = vnode.attrs.builder,
            email = prop(''),
            error = prop(false),
            submit = () => {
                if (h.validateEmail(email())) {
                    return true;
                }
                error(true);
                return false;
            };
        vnode.state = {
            email,
            submit,
            error
        };
    },
    view: function({state, attrs}) {
        const errorClasses = (!state.error) ? '.positive.error' : '';
        return m(`form.w-form[id="email-form"][method="post"][action="${attrs.builder.customAction}"]`, {
            onsubmit: state.submit
        }, [
            m('.w-col.w-col-5', [
                m(`input${errorClasses}.w-input.text-field.medium[name="EMAIL"][placeholder="Digite seu email"][type="text"]`, {
                    oncreate: h.RDTracker('landing-flex'),
                    onchange: m.withAttr('value', state.email),
                    value: state.email()
                }),
                (state.error() ? m('span.fontsize-smaller.text-error', 'E-mail inválido') : '')
            ]),
            m('.w-col.w-col-3', [
                m('input.w-button.btn.btn-large[type="submit"][value="Cadastrar"]')
            ])
        ]);
    }
};

export default landingSignup;
