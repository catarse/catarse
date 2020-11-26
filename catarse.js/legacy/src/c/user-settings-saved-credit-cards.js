import m from 'mithril';
import _ from 'underscore';
import h from '../h';

const I18nScope = _.partial(h.i18nScope, 'users.edit.settings_tab');

const userSettingsSavedCreditCards = {
    view: function({attrs}) {
        const 
            user = attrs.user,
            creditCards = attrs.creditCards(),
            setCardDeletionForm = attrs.setCardDeletionForm,
            deleteCard = attrs.deleteCard,
            toDeleteCard = attrs.toDeleteCard;

        return m('.w-form.card.card-terciary.u-marginbottom-20', [
            m('.fontsize-base.fontweight-semibold',
                window.I18n.t('credit_cards.title', I18nScope())
            ),
            m('.fontsize-small.u-marginbottom-20',
                m.trust(
                    window.I18n.t('credit_cards.subtitle', I18nScope())
                )
            ),
            m('.divider.u-marginbottom-20'),
            m('.w-row.w-hidden-tiny.card', [
                m('.w-col.w-col-5.w-col-small-5',
                    m('.fontsize-small.fontweight-semibold',
                        window.I18n.t('credit_cards.card_label', I18nScope())
                    )
                ),
                m('.w-col.w-col-5.w-col-small-5',
                    m('.fontweight-semibold.fontsize-small',
                        window.I18n.t('credit_cards.provider_label', I18nScope())
                    )
                ),
                m('.w-col.w-col-2.w-col-small-2')
            ]),

            (_.map(creditCards, card => m('.w-row.card', [
                m('.w-col.w-col-5.w-col-small-5',
                    m('.fontsize-small.fontweight-semibold', [
                        'XXXX XXXX XXXX',
                        m.trust('&nbsp;'),
                        card.last_digits
                    ])
                ),
                m('.w-col.w-col-5.w-col-small-5',
                    m('.fontsize-small.fontweight-semibold.u-marginbottom-10',
                        card.card_brand.toUpperCase()
                    )
                ),
                m('.w-col.w-col-2.w-col-small-2',
                    m('a.btn.btn-terciary.btn-small[rel=\'nofollow\']', {
                        onclick: deleteCard(card.id)
                    },
                        window.I18n.t('credit_cards.remove_label', I18nScope())
                    )
                )
            ]))),
            m('form.w-hidden', {
                action: `/${window.I18n.locale}/users/${user.id}/credit_cards/${toDeleteCard()}`,
                method: 'POST',
                oncreate: setCardDeletionForm
            }, [
                m('input[name=\'utf8\'][type=\'hidden\'][value=\'✓\']'),
                m('input[name=\'_method\'][type=\'hidden\'][value=\'delete\']'),
                m(`input[name='authenticity_token'][type='hidden'][value='${h.authenticityToken()}']`),
            ])
        ]);
    }

};

export default userSettingsSavedCreditCards;
