import m from 'mithril';
import _ from 'underscore';
import bigCard from './big-card';
import h from '../h';

const I18nScope = _.partial(h.i18nScope, 'users.edit.settings_tab.change_password');

const userSettingsChangePassword = {
    view: function({attrs}) 
    {
        const fields = attrs.fields(),
              parsedErrors = attrs.parsedErrors;
        
        return m(bigCard, 
            {
                label: window.I18n.t('title', I18nScope()),
                label_hint: window.I18n.t('subtitle', I18nScope()),
                children: [                
                    m('.divider.u-marginbottom-20'),  
                    m('.w-row',
                        m('.w-col.w-col-6.w-sub-col', [
                            m('label.field-label.fontweight-semibold', window.I18n.t('current_label', I18nScope())),
                            m('input.password.optional.w-input.text-field.w-input.text-field.positive[id=\'user_current_password\'][name=\'user[current_password]\'][type=\'password\']', {
                                class: parsedErrors.hasError('current_password') ? 'error' : false,
                                value: fields.current_password(),
                                onchange: m.withAttr('value', fields.current_password)
                            }),
                            parsedErrors.inlineError('current_password')
                        ]),
                        m('.w-col.w-col-6', [
                            m('label.field-label.fontweight-semibold', window.I18n.t('new_label', I18nScope())),
                            m('input.password.optional.w-input.text-field.w-input.text-field.positive[id=\'user_password\'][name=\'user[password]\'][type=\'password\']', {
                                class: parsedErrors.hasError('password') ? 'error' : false,
                                value: fields.password(),
                                onchange: m.withAttr('value', fields.password)
                            }),
                            parsedErrors.inlineError('password')
                        ])
                    )
                    
                ]
            });
        
    }
};

export default userSettingsChangePassword;
