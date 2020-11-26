import m from 'mithril';
import prop from 'mithril/stream';
import h from '../h';
import _ from 'underscore';
import { catarse, commonNotification } from '../api';
import models from '../models';
import projectEditSaveBtn from '../c/project-edit-save-btn';

const adminNotifications = {
    oninit: function(vnode) {
        const templates = commonNotification.paginationVM(
            models.notificationTemplates, 'label.asc'),
            loaderTemp = prop(true),
            loaderSubmit = prop(false),
            selectedItem = prop(),
            selectedItemTemplate = prop(),
            renderedTemplate = prop(),
            renderedSubjectTemplate = prop(),
            parsedTemplate = prop(),
            parsedSubjectTemplate = prop(),
            selectedItemSubjectTemplate = prop(),
            templateDefaultVars = {
                user: {
                    name: 'test name user'
                }
            },
            renderSubjectTemplate = (tpl) => {},
            renderTemplate = (tpl) => {},
            changeSelectedTo = collection => (evt) => {
                const item = _.find(collection, { label: evt.target.value });

                if (item && item.label) {
                    const tpl = item.template || item.default_template;
                    const subTpl = item.subject || item.default_subject;

                    selectedItem(item);
                    selectedItemTemplate(tpl);
                    selectedItemSubjectTemplate(subTpl);
                    renderSubjectTemplate(subTpl);
                    renderTemplate(tpl);
                } else { selectedItem(undefined); }
            },
            onSaveSelectedItem = (evt) => {
                loaderSubmit(true);
                models.commonNotificationTemplate.postWithToken({
                    data: {
                        label: selectedItem().label,
                        subject: parsedSubjectTemplate(),
                        template: parsedTemplate()
                    }
                }, null, {}).then(() => {
                    templates.firstPage({}).then(() => { loaderSubmit(false); });
                });
            };

        templates.firstPage({}).then(() => { loaderTemp(false); });

        vnode.state = {
            templates,
            selectedItem,
            selectedItemTemplate,
            renderedTemplate,
            renderTemplate,
            changeSelectedTo,
            loaderTemp,
            onSaveSelectedItem,
            loaderSubmit,
            renderSubjectTemplate,
            selectedItemSubjectTemplate
        };
    },
    view: function({state}) {
        const templatesCollection = state.templates.collection(),
            selectedItem = state.selectedItem();

        return m('', [
            m('#notifications-admin', [
                m('.section',
					m('.w-container',
						m('.w-row', [
    m('.w-col.w-col-3'),
    m('.w-col.w-col-6',
								m('.w-form', [
    m('form', [
        m('.fontsize-larger.u-marginbottom-10.u-text-center',
											'Notificações'
										),
										(state.loaderTemp() && !_.isEmpty(templatesCollection) ? h.loader() : m(
											'select.medium.text-field.w-select', {
    oninput: state.changeSelectedTo(templatesCollection)
}, (() => {
    const maped = _.map(
													templatesCollection,
													item => m('option', { value: item.label }, item.label)
												);
    maped.unshift(m("option[value='']", 'Selecione uma notificação'));
    return maped;
})())
										)
    ])
])
							),
    m('.w-col.w-col-3')
])
					)
				),
                m('.divider'),
                m('.u-marginbottom-80.bg-gray.section',
					(selectedItem ? m('.w-container',
						m('.w-row', [
    m('.w-col.w-col-6', [
        m('.fontsize-base.fontweight-semibold.u-marginbottom-20.u-text-center', [
            m('span.fa.fa-code',
										''
									),
            'HTML'
        ]),
        m('.w-form', [
            m('form', [
                m('.u-marginbottom-20.w-row', [
                    m('.w-col.w-col-2',
												m('label.fontsize-small',
													'Label'
												)
											),
                    m('.w-col.w-col-10',
												m('.fontsize-small',
													selectedItem.label
												)
											)
                ]),
                m('.w-row', [
                    m('.w-col.w-col-2',
												m('label.fontsize-small',
													'Subject'
												)
											),
                    m('.w-col.w-col-10',
												m('input.positive.text-field.w-input', {
    value: state.selectedItemSubjectTemplate(),
    oninput: m.withAttr('value', (v) => {
        state.selectedItemSubjectTemplate(v);
        state.renderSubjectTemplate(v);
    })
})
											)
                ]),
                m('label.fontsize-small', [
                    'Content',
                    m('a.alt-link.u-right',
												'Ver variáveis'
											)
                ]),
                m('textarea.positive.text-field.w-input[rows="20"]', {
                    value: state.selectedItemTemplate(),
                    oninput: m.withAttr('value', (v) => {
                        state.selectedItemTemplate(v);
                        state.renderTemplate(v);
                    })
                })
            ])
        ])
    ]),
    m('.w-col.w-col-6', [
        m('.fontsize-base.fontweight-semibold.u-marginbottom-20.u-text-center', [
            m('span.fa.fa-eye', ''),
            'Visualização'
        ]),
        m('', m.trust(state.renderedTemplate()))
    ])
])
					) : '')
				)
            ]),
			(selectedItem ? m('footer', m(projectEditSaveBtn, {
    loading: state.loaderSubmit,
    onSubmit: state.onSaveSelectedItem,
    hideMarginLeft: true
})) : '')
        ]);
    }
};

export default adminNotifications;
