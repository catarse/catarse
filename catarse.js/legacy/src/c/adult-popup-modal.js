import m from 'mithril';

/**
 * @typedef {Object} AdultPopupModalAttrs
 * @property {string} userPublicName
 * @property {string} userPhotoUrl
 * @property {() => void} onAgree
 */

export const AdultPopupModal = {
    view({ attrs }) {

        /** @type {AdultPopupModalAttrs} */
        const {
            userPublicName,
            userPhotoUrl,
            onAgree
        } = attrs;

        return m('div.modal-dialog-content',
            [
                m('div.w-row',
                    [
                        m('div.w-col.w-col-1'),
                        m('div.w-col.w-col-10',
                            m('div.fontsize-large.u-text-center.fontweight-semibold',
                                '✋Você precisa ser maior de 18 anos para acessar esta página'
                            )
                        ),
                        m('div.w-col.w-col-1')
                    ]
                ),
                m('div.u-text-center.u-margintop-30',
                    [
                        m(`img.thumb.big.u-round.u-marginbottom-40[src='${userPhotoUrl}'][alt='Foto do Perfil do Realizador']`),
                        m('div.fontsize-base.u-marginbottom-40', [
                            'Esse projeto de ',
                            m('span.fontweight-semibold', userPublicName),
                            ' apresenta conteúdos e imagens impróprias para menores de idade. Você é maior de 18 anos?'
                        ]),
                        m('a.btn.btn-medium.btn-inline.u-marginbottom-20', 
                            { 
                                'style': { 'transition': 'all 0.5s ease 0s' },
                                onclick: onAgree
                            },
                            'Sim. Tenho mais de 18 anos'
                        ),
                        m('div.fontsize-smallest',
                            [
                                'De acordo com os ',
                                m('a.alt-link[href="https://crowdfunding.catarse.me/legal/termos-de-uso"][target="_blank"]',
                                    'termos de uso'
                                ),
                                ' do Catarse.'
                            ]
                        )
                    ]
                )
            ]
        );
    }
}