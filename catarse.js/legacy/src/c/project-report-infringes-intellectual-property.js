/**
 * window.c.projectReportInfringesIntellectulaProperty component
 * Render project report form
 *
 */
import m from 'mithril';
import prop from 'mithril/stream';
import _ from 'underscore';
import { catarse } from '../api';
import models from '../models';
import h from '../h';
import inlineError from './inline-error';

const projectReportInfringesIntellectualProperty = {
	oninit: function (vnode) {
		const formName = 'report-infringes-intellectual-property',
			relationWithViolatedPropertyError = prop(false),
			fullNameError = prop(false),
			fullAddressError = prop(false),
			projectInfringesError = prop(false),
			detailsError = prop(false),
			termsAgreedError = prop(false),
			validate = () => {
				relationWithViolatedPropertyError(_.isEmpty(vnode.attrs.relationWithViolatedProperty()));
				fullNameError(_.isEmpty(vnode.attrs.fullName()));
				fullAddressError(_.isEmpty(vnode.attrs.fullAddress()));
				projectInfringesError(_.isEmpty(vnode.attrs.projectInfringes()));
				detailsError(_.isEmpty(vnode.attrs.details()));
				termsAgreedError(!vnode.attrs.termsAgreed());

				if (!relationWithViolatedPropertyError() &&
					!fullNameError() &&
					!fullAddressError() &&
					!projectInfringesError() &&
					!detailsError() &&
					!termsAgreedError()
				) {
					vnode.attrs.reason('Este projeto infringe propriedade intelectual');
					return true;
				}
				return false;
			};

		vnode.state = {
			formName: vnode.attrs.formName || formName,
			relationWithViolatedPropertyError,
			fullNameError,
			fullAddressError,
			projectInfringesError,
			detailsError,
			termsAgreedError,
			sendReport: vnode.attrs.sendReport.bind(vnode.attrs.sendReport, validate)
		};
	},
	view: function ({ state, attrs }) {
		const assertError = (condition, message) => condition ? m(inlineError, { message }) : '';

		return m('.card.u-radius.u-margintop-20',
			m('.w-form',
				[
					m('form', {
						onsubmit: state.sendReport,
						oncreate: state.checkScroll
					},
						[
							m('.report-option.w-radio',
								[
									m('input.w-radio-input[type=\'radio\']', {
										value: state.formName,
										onchange: m.withAttr('value', attrs.displayFormWithName),
										checked: attrs.displayFormWithName() === state.formName
									}),
									m('label.fontsize-small.fontweight-semibold.w-form-label', {
										onclick: () => attrs.displayFormWithName(state.formName)
									}, 'Este projeto infringe propriedade intelectual')
								]
							),
							m('.fontsize-smaller.fontcolor-secondary',
								'O projeto está infringindo de algum modo seus direitos de propriedade intelectual.'
							),
							m('.u-margintop-30', {
								style: {
									display: attrs.displayFormWithName() === state.formName ? 'block' : 'none'
								}
							},
								[
									m('.u-marginbottom-30',
										[
											m('.fontsize-smaller.fontweight-semibold.u-marginbottom-10',
												'Sua relação com a propriedade que está sendo violada *'
											),
											m('.fontsize-smaller.fontcolor-secondary.u-marginbottom-10.card.u-radius.card-message',
												[
													m('span.fontweight-bold',
														'Importante:'
													),
													'A denúncia deve ser realizada pela',
													m.trust('&nbsp;'),
													'pessoa, empresa ou responsável legal',
													m.trust('&nbsp;'),
													'pelo direito envolvido. Caso não seja esse o seu caso, notifique diretamente o responsável pela propriedade que você acredita estar sendo violada.'
												]
											),
											m('.u-marginbottom-10.w-radio',
												[
													m('input.w-radio-input[type=\'radio\']', {
														value: 'Sou dono dos direitos',
														checked: attrs.relationWithViolatedProperty() === 'Sou dono dos direitos',
														onchange: m.withAttr('value', attrs.relationWithViolatedProperty)
													}),
													m('label.fontsize-smaller.w-form-label', {
														onclick: () => attrs.relationWithViolatedProperty('Sou dono dos direitos')
													}, 'Sou dono dos direitos')
												]
											),
											m('.u-marginbottom-10.w-radio',
												[
													m('input.w-radio-input[type=\'radio\']', {
														value: 'Sou representante do dono dos direitos',
														checked: attrs.relationWithViolatedProperty() === 'Sou representante do dono dos direitos',
														onchange: m.withAttr('value', attrs.relationWithViolatedProperty)
													}),
													m('label.fontsize-smaller.w-form-label', {
														onclick: () => attrs.relationWithViolatedProperty('Sou representante do dono dos direitos')
													}, 'Sou representante do dono dos direitos')
												]
											),
											assertError(state.relationWithViolatedPropertyError(), 'Indique sua relação com a propriedade violada')
										]
									),
									m('.fontsize-smaller.fontweight-semibold',
										'Nome completo *'
									),
									m('input.text-field.positive.w-input[maxlength=\'256\'][type=\'text\']', {
										onchange: m.withAttr('value', attrs.fullName),
										class: {
											error: state.fullNameError()
										}
									}),
									assertError(state.fullNameError(), 'Informe seu nome completo'),
									m('.w-row',
										[
											m('.w-sub-col.w-col.w-col-6',
												[
													m('.fontsize-smaller.fontweight-semibold',
														'CPF'
													),
													m('input.text-field.positive.w-input[maxlength=\'256\'][type=\'text\']', {
														onchange: m.withAttr('value', attrs.CPF)
													})
												]
											),
											m('.w-col.w-col-6',
												[
													m('.fontsize-smaller.fontweight-semibold',
														'Telefone'
													),
													m('input.text-field.positive.w-input[maxlength=\'256\'][type=\'text\']', {
														onchange: m.withAttr('value', attrs.telephone)
													})
												]
											)
										]
									),
									m('.w-row',
										[
											m('.w-sub-col.w-col.w-col-6',
												[
													m('.fontsize-smaller.fontweight-semibold',
														'Nome da empresa (caso aplicável)'
													),
													m('input.text-field.positive.w-input[maxlength=\'256\'][type=\'text\']', {
														onchange: m.withAttr('value', attrs.businessName)
													})
												]
											),
											m('.w-col.w-col-6',
												[
													m('.fontsize-smaller.fontweight-semibold',
														'CNPJ (caso aplicável)'
													),
													m('input.text-field.positive.w-input[maxlength=\'256\'][type=\'text\']', {
														onchange: m.withAttr('value', attrs.CNPJ)
													})
												]
											)
										]
									),
									m('.w-row',
										[
											m('.w-sub-col.w-col.w-col-6',
												[
													m('.fontsize-smaller.fontweight-semibold',
														'Cargo (caso aplicável)'
													),
													m('input.text-field.positive.w-input[maxlength=\'256\'][type=\'text\']', {
														onchange: m.withAttr('value', attrs.businessRole)
													})
												]
											),
											m('.w-col.w-col-6')
										]
									),
									m('.fontsize-smaller.fontweight-semibold',
										'Endereço completo *'
									),
									m('input.text-field.positive.w-input[maxlength=\'256\'][type=\'text\']', {
										onchange: m.withAttr('value', attrs.fullAddress),
										class: {
											error: state.fullAddressError()
										}
									}),
									assertError(state.fullAddressError(), 'Informe seu endereço completo'),
									m('.fontsize-smaller.fontweight-semibold',
										'Este projeto está infringindo *'
									),
									m('select.text-field.positive.w-select', {
										onchange: m.withAttr('value', attrs.projectInfringes),
										class: {
											error: state.projectInfringesError()
										}
									},
										[
											m('option[value=\'\']',
												'Selecione uma opção'
											),
											m('option[value=\'Marcas\']',
												'Marcas'
											),
											m('option[value=\'Patentes\']',
												'Patentes'
											),
											m('option[value=\'Desenho Industrial\']',
												'Desenho Industrial'
											),
											m('option[value=\'Direitos autorais\']',
												'Direitos autorais'
											),
											m('option[value=\'Direitos de software\']',
												'Direitos de software'
											),
											m('option[value=\'Modelo industrial\']',
												'Modelo industrial'
											)
										]
									),
									assertError(state.projectInfringesError(), 'Indique uma opção'),
									m('.u-marginbottom-30',
										[
											m('.fontsize-smaller.fontweight-semibold',
												'Detalhes da denúncia *'
											),
											m('textarea.text-field.positive.w-input[maxlength=\'5000\']', {
												onchange: m.withAttr('value', attrs.details),
												placeholder: 'Por favor, dê mais detalhes que nos ajudem a identificar o problema',
												class: {
													error: state.detailsError()
												}
											}),
											assertError(state.detailsError(), 'Informe os detalhes da denúncia')
										]
									),
									/*
												  m('.u-marginbottom-30',
													  [
															m('.fontsize-smaller.fontweight-semibold',
																'Documentos comprobatórios'
															 ),
															m('.fontsize-smaller.fontcolor-secondary',
																'Faça upload de documentos que possam ajudar na denúncia. Caso você tenha mais de 01 documento, por favor junte todos em um único arquivo comprimido.'
															 )
													  ]
												   ), */
									m('.u-marginbottom-40',
										[
											m('.w-checkbox',
												[
													m('input.w-checkbox-input[id=\'checkbox\'][type=\'checkbox\']', {
														value: attrs.termsAgreed(),
														onchange: () => attrs.termsAgreed(!attrs.termsAgreed()),
														checked: attrs.termsAgreed()
													}),
													m('label.fontsize-smaller.w-form-label[for=\'checkbox\']',
														'Asseguro, com a consciência de que o envio de denúncias com conteúdo enganoso pode ser punível por lei, que as informações que forneço aqui são verdadeiras.'
													)
												]
											),
											assertError(state.termsAgreedError(), 'Confirme o campo acima para enviar a denúncia')
										]
									),
									m('input.btn.btn-medium.btn-inline.btn-dark.w-button[type=\'submit\'][value=\'Enviar denúncia\']', {
										disabled: attrs.submitDisabled()
									})
								]
							)
						]
					)
				]
			)
		);
	}
};

export default projectReportInfringesIntellectualProperty;
