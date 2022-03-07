import m from 'mithril';
import _ from 'underscore';
import bigCard from './big-card';
import h from '../h';

const I18nScope = _.partial(h.i18nScope, 'users.edit.settings_tab.delete_account');

const userSettingsDeleteAccount = {
    view: function({attrs})
    {
        const userId = attrs.idUser();

        return m(bigCard, {
            label: window.I18n.t('title', I18nScope()),
            label_hint: window.I18n.t('subtitle', I18nScope()),
            children: [
                m('.divider.u-marginbottom-20'),                 
                m('.w-row', [
                    m(`a.alt-link.fontsize-smaller[href='/${window.I18n.locale}/users/${userId}'][rel='nofollow']`, {
                        onclick: attrs.deleteAccount
                    },
                        window.I18n.t('label', I18nScope())
                    ),
                    m('form.w-hidden', {
                        action: `/${window.I18n.locale}/users/${userId}`,
                        method: 'post',
                        oncreate: attrs.setDeleteForm                        
                    }, [
                        m(`input[name='authenticity_token'][type='hidden'][value='${h.authenticityToken()}']`),
                        m('input[name=\'_method\'][type=\'hidden\'][value=\'delete\']')
                    ])

                ])
            ]   
        });
    }
};

export default userSettingsDeleteAccount;
