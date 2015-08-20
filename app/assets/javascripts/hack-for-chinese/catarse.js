/*
    Catarse JS components
    Copyright (c) 2007 - 2015 Diogo Biazus
    Licensed under the MIT license
    Version: 1.0.0
*/
window.c = function() {
    return {
        models: {},
        pages: {},
        admin: {},
        h: {}
    };
}(), window.c.h = function(m, moment) {
    var momentify = function(date, format) {
        return format = format || "DD/MM/YYYY", date ? moment(date).format(format) : "no date";
    }, momentFromString = function(date, format) {
        var european = moment(date, format || "DD/MM/YYYY");
        return european.isValid() ? european : moment(date);
    }, generateFormatNumber = function(s, c) {
        return function(number, n, x) {
            if (null === number || void 0 === number) return null;
            var re = "\\d(?=(\\d{" + (x || 3) + "})+" + (n > 0 ? "\\D" : "$") + ")", num = number.toFixed(Math.max(0, ~~n));
            return (c ? num.replace(".", c) : num).replace(new RegExp(re, "g"), "$&" + (s || ","));
        };
    }, formatNumber = generateFormatNumber(".", ","), toggleProp = function(defaultState, alternateState) {
        var p = m.prop(defaultState);
        return p.toggle = function() {
            p(p() === alternateState ? defaultState : alternateState);
        }, p;
    }, loader = function() {
        return m('.u-text-center.u-margintop-30[style="margin-bottom:-110px;"]', [ m('img[alt="Loader"][src="https://s3.amazonaws.com/catarse.files/loader.gif"]') ]);
    };
    return {
        momentify: momentify,
        momentFromString: momentFromString,
        formatNumber: formatNumber,
        toggleProp: toggleProp,
        loader: loader
    };
}(window.m, window.moment), window.c.models = function(m) {
    var contributionDetail = m.postgrest.model("contribution_details"), teamTotal = m.postgrest.model("team_totals", [ "member_count", "countries", "total_contributed_projects", "total_cities", "total_amount" ]), teamMember = m.postgrest.model("team_members");
    return teamMember.pageSize(40), {
        contributionDetail: contributionDetail,
        teamTotal: teamTotal,
        teamMember: teamMember
    };
}(window.m), window.c.admin.Contributions = function(m, c, h) {
    var admin = c.admin;
    return {
        controller: function() {
            var listVM = admin.contributionListVM, filterVM = admin.contributionFilterVM, itemBuilder = [ {
                component: "AdminUser",
                wrapperClass: ".w-col.w-col-4"
            }, {
                component: "AdminProject",
                wrapperClass: ".w-col.w-col-4"
            }, {
                component: "AdminContribution",
                wrapperClass: ".w-col.w-col-2"
            }, {
                component: "PaymentStatus",
                wrapperClass: ".w-col.w-col-2"
            } ], error = m.prop(""), submit = function() {
                return listVM.firstPage(filterVM.parameters()).then(null, function(serverError) {
                    error(serverError.message);
                }), !1;
            };
            return {
                filterVM: filterVM,
                itemBuilder: itemBuilder,
                listVM: {
                    list: listVM,
                    error: error
                },
                submit: submit
            };
        },
        view: function(ctrl) {
            return [ m.component(c.AdminFilter, {
                form: ctrl.filterVM.formDescriber,
                submit: ctrl.submit
            }), m.component(c.AdminList, {
                vm: ctrl.listVM,
                itemBuilder: ctrl.itemBuilder
            }) ];
        }
    };
}(window.m, window.c, window.c.h), window.c.admin.contributionFilterVM = function(m, h, replaceDiacritics) {
    var vm = m.postgrest.filtersVM({
        full_text_index: "@@",
        state: "eq",
        gateway: "eq",
        value: "between",
        created_at: "between"
    });
    return vm.formDescriber = [ {
        type: "main",
        data: {
            vm: vm.full_text_index,
            placeholder: "搜索项目，邮件地址或者ID..."
        }
    }, {
        type: "dropdown",
        data: {
            label: "状态",
            name: "state",
            vm: vm.state,
            options: [ {
                value: "",
                option: "任意"
            }, {
                value: "paid",
                option: "已支付"
            }, {
                value: "refused",
                option: "被拒绝"
            }, {
                value: "pending",
                option: "等待"
            }, {
                value: "pending_refund",
                option: "退款等待"
            }, {
                value: "refunded",
                option: "已退款"
            }, {
                value: "chargeback",
                option: "退单"
            }, {
                value: "deleted",
                option: "已删除"
            } ]
        }
    }, {
        type: "dropdown",
        data: {
            label: "支付方式",
            name: "gateway",
            vm: vm.gateway,
            options: [ {
                value: "",
                option: "任意"
            }, {
                value: "Pagarme",
                option: "Pagarme"
            }, {
                value: "MoIP",
                option: "MoIP"
            }, {
                value: "PayPal",
                option: "PayPal"
            }, {
                value: "Credits",
                option: "Créditos"
            } ]
        }
    }, {
        type: "numberRange",
        data: {
            label: "价格区间",
            first: vm.value.gte,
            last: vm.value.lte
        }
    }, {
        type: "dateRange",
        data: {
            label: "有效期",
            first: vm.created_at.gte,
            last: vm.created_at.lte
        }
    } ], vm.state(""), vm.gateway(""), vm.order({
        id: "desc"
    }), vm.created_at.lte.toFilter = function() {
        return h.momentFromString(vm.created_at.lte()).endOf("day").format("");
    }, vm.created_at.gte.toFilter = function() {
        return h.momentFromString(vm.created_at.gte()).format();
    }, vm.full_text_index.toFilter = function() {
        return replaceDiacritics(vm.full_text_index());
    }, vm;
}(window.m, window.c.h, window.replaceDiacritics), window.c.admin.contributionListVM = function(m, models) {
    return m.postgrest.paginationVM(models.contributionDetail.getPageWithToken);
}(window.m, window.c.models), window.c.AdminContribution = function(m, h) {
    return {
        view: function(ctrl, args) {
            var contribution = args.item;
            return m(".w-row", [ m(".fontweight-semibold.lineheight-tighter.u-marginbottom-10.fontsize-small", "R$" + contribution.value), m(".fontsize-smallest.fontcolor-secondary", h.momentify(contribution.created_at, "DD/MM/YYYY HH:mm[h]")), m(".fontsize-smallest", [ "ID do Gateway: ", m('a.alt-link[target="_blank"][href="https://dashboard.pagar.me/#/transactions/' + contribution.gateway_id + '"]', contribution.gateway_id) ]) ]);
        }
    };
}(window.m, window.c.h), window.c.AdminDetail = function(m, c) {
    return {
        controller: function() {
            return {
                displayRequestRefundDropDown: c.ToggleDiv.toggler(),
                displayRefundDropDown: c.ToggleDiv.toggler(),
                displayTransferContributionDropDown: c.ToggleDiv.toggler(),
                displayChangeRewardDropDown: c.ToggleDiv.toggler(),
                displatAnonDropDown: c.ToggleDiv.toggler()
            };
        },
        view: function(ctrl, args) {
            var contribution = args.item;
            return m("#admin-contribution-detail-box", [ m(".divider.u-margintop-20.u-marginbottom-20"), m(".w-row.u-marginbottom-30.w-hidden", [ m(".w-col.w-col-2", [ m("button.btn.btn-small.btn-terciary", {
                onclick: ctrl.displayRequestRefundDropDown.toggle
            }, "Pedir reembolso"), m.component(c.ToggleDiv, {
                display: ctrl.displayRequestRefundDropDown,
                content: m('.dropdown-list.card.u-radius.dropdown-list-medium.zindex-10[id="transfer"]', [ m(".fontsize-smaller.fontweight-semibold.u-text-center.u-marginbottom-20", "Quer efetuar o reembolso?"), m("button.btn.btn-small", "Solicitar reembolso") ])
            }) ]), m(".w-col.w-col-2", [ m("button.btn.btn-small.btn-terciary", {
                onclick: ctrl.displayRefundDropDown.toggle
            }, "Estornar"), m.component(c.ToggleDiv, {
                display: ctrl.displayRefundDropDown,
                content: m(".dropdown-list.card.u-radius.dropdown-list-medium.zindex-10", [ m(".fontsize-smaller.fontweight-semibold.u-text-center.u-marginbottom-20", "Quer efetuar o estorno?"), m("button.btn.btn-small", "Solicitar estorno") ])
            }) ]), m(".w-col.w-col-2", [ m("button.btn.btn-small.btn-terciary.btn-desactivated", "2a via") ]), m(".w-col.w-col-2", [ m("button.btn.btn-small.btn-terciary", {
                onclick: ctrl.displayTransferContributionDropDown.toggle
            }, "Transferir apoio"), m.component(c.ToggleDiv, {
                display: ctrl.displayTransferContributionDropDown,
                content: m(".dropdown-list.card.u-radius.dropdown-list-medium.zindex-10", [ m(".w-form", [ m("form", [ m("label", "Id do novo apoiador:"), m('input.w-input.text-field[placeholder="ex: 129908"][type="text"]'), m('input.w-button.btn.btn-small[type="submit"][value="Transferir"]') ]) ]) ])
            }) ]), m(".w-col.w-col-2", [ m("button.btn.btn-small.btn-terciary", {
                onclick: ctrl.displayChangeRewardDropDown.toggle
            }, "Trocar recompensa"), m.component(c.ToggleDiv, {
                display: ctrl.displayChangeRewardDropDown,
                content: m('.dropdown-list.card.u-radius.dropdown-list-medium.zindex-10[id="transfer"]', {
                    style: {
                        display: "none"
                    }
                }, [ m(".w-form", [ m("form", [ m(".w-radio", [ m('input.w-radio-input[type="radio"][value="Radio"]'), m("label.w-form-label", "R$ 10") ]), m(".w-radio", [ m('input.w-radio-input[type="radio"][value="Radio"]'), m('label.w-form-label[for="radio"]', "R$ 10") ]), m(".w-radio", [ m('input.w-radio-input[type="radio"][value="Radio"]'), m("label.w-form-label", "R$ 10") ]), m(".w-radio", [ m('input.w-radio-input[type="radio"][value="Radio"]'), m("label.w-form-label", "R$ 10") ]), m(".w-radio", [ m('input.w-radio-input[type="radio"][value="Radio"]'), m("label.w-form-label", "R$ 10") ]) ]) ]) ])
            }) ]), m(".w-col.w-col-2", [ m("button.btn.btn-small.btn-terciary", {
                onclick: ctrl.displatAnonDropDown.toggle
            }, "Anonimato"), m.component(c.ToggleDiv, {
                display: ctrl.displatAnonDropDown,
                content: m(".dropdown-list.card.u-radius.dropdown-list-medium.zindex-10", [ m(".w-form", [ m("form", [ m(".w-radio", [ m('input.w-radio-input[type="radio"]'), m("label.w-form-label", "Anônimo") ]), m(".w-radio", [ m('input.w-radio-input[type="radio"][value="Radio"]'), m("label.w-form-label", "Público") ]) ]) ]) ])
            }) ]) ]), m(".w-row.card.card-terciary.u-radius", [ m.component(c.AdminTransaction, {
                contribution: contribution
            }), m.component(c.AdminTransactionHistory, {
                contribution: contribution
            }), m.component(c.AdminReward, {
                contribution: contribution,
                key: contribution.key
            }) ]) ]);
        }
    };
}(window.m, window.c), window.c.AdminFilter = function(c, m, _, h) {
    return {
        controller: function() {
            return {
                toggler: h.toggleProp(!1, !0)
            };
        },
        view: function(ctrl, args) {
            var formBuilder = function(data) {
                return {
                    main: m.component(c.FilterMain, data),
                    dropdown: m.component(c.FilterDropdown, data),
                    numberRange: m.component(c.FilterNumberRange, data),
                    dateRange: m.component(c.FilterDateRange, data)
                };
            }, main = _.findWhere(args.form, {
                type: "main"
            });
            return m("#admin-contributions-filter.w-section.page-header", [ m(".w-container", [ m(".fontsize-larger.u-text-center.u-marginbottom-30", "项目"), m(".w-form", [ m("form", {
                onsubmit: args.submit
            }, [ formBuilder(main.data).main, m(".u-marginbottom-20.w-row", m('button.w-col.w-col-12.fontsize-smallest.link-hidden-light[style="background: none; border: none; outline: none; text-align: left;"][type="button"]', {
                onclick: ctrl.toggler.toggle
            }, "筛选  >")), ctrl.toggler() ? m("#advanced-search.w-row.admin-filters", [ _.map(args.form, function(f) {
                return "main" !== f.type ? formBuilder(f.data)[f.type] : "";
            }) ]) : "" ]) ]) ]) ]);
        }
    };
}(window.c, window.m, window._, window.c.h), window.c.AdminItem = function(m, _, h, c) {
    return {
        controller: function(args) {
            var displayDetailBox = h.toggleProp(!1, !0);
            return {
                displayDetailBox: displayDetailBox
            };
        },
        view: function(ctrl, args) {
            var item = args.item;
            return m(".w-clearfix.card.u-radius.u-marginbottom-20.results-admin-items", [ m(".w-row", [ _.map(args.builder, function(component) {
                return m(component.wrapperClass, [ m.component(c[component.component], {
                    item: item,
                    key: item.key
                }) ]);
            }) ]), m("button.w-inline-block.arrow-admin.fa.fa-chevron-down.fontcolor-secondary", {
                onclick: ctrl.displayDetailBox.toggle
            }), ctrl.displayDetailBox() ? m.component(c.AdminDetail, {
                item: item,
                key: item.key
            }) : "" ]);
        }
    };
}(window.m, window._, window.c.h, window.c), window.c.AdminList = function(m, h, c) {
    c.admin;
    return {
        controller: function(args) {
            var list = args.vm.list;
            !list.collection().length && list.firstPage && list.firstPage().then(null, function(serverError) {
                args.vm.error(serverError.message);
            });
        },
        view: function(ctrl, args) {
            var list = args.vm.list, error = args.vm.error;
            return m(".w-section.section", [ m(".w-container", error() ? m(".card.card-error.u-radius.fontweight-bold", error()) : [ m(".w-row.u-marginbottom-20", [ m(".w-col.w-col-9", [ m(".fontsize-base", list.isLoading() ? "Buscando apoios..." : [ m("span.fontweight-semibold", list.total()), " apoios encontrados" ]) ]) ]), m("#admin-contributions-list.w-container", [ list.collection().map(function(item) {
                return m.component(c.AdminItem, {
                    builder: args.itemBuilder,
                    item: item,
                    key: item.key
                });
            }), m(".w-section.section", [ m(".w-container", [ m(".w-row", [ m(".w-col.w-col-2.w-col-push-5", [ list.isLoading() ? h.loader() : m("button#load-more.btn.btn-medium.btn-terciary", {
                onclick: list.nextPage
            }, "Carregar mais") ]) ]) ]) ]) ]) ]) ]);
        }
    };
}(window.m, window.c.h, window.c), window.c.AdminProject = function(m, h) {
    return {
        view: function(ctrl, args) {
            var project = args.item;
            return m(".w-row", [ m(".w-col.w-col-3.w-col-small-3.u-marginbottom-10", [ m("img.thumb-project.u-radius[src=" + project.project_img + "][width=50]") ]), m(".w-col.w-col-9.w-col-small-9", [ m(".fontweight-semibold.fontsize-smaller.lineheight-tighter.u-marginbottom-10", [ m('a.alt-link[target="_blank"][href="/' + project.permalink + '"]', project.project_name) ]), m(".fontsize-smallest.fontweight-semibold", project.project_state), m(".fontsize-smallest.fontcolor-secondary", h.momentify(project.project_online_date) + " a " + h.momentify(project.project_expires_at)) ]) ]);
        }
    };
}(window.m, window.c.h), window.c.AdminReward = function(m, h, _) {
    return {
        view: function(ctrl, args) {
            var reward = args.contribution.reward || {}, available = parseInt(reward.paid_count) + parseInt(reward.waiting_payment_count);
            return m(".w-col.w-col-4", [ m(".fontweight-semibold.fontsize-smaller.lineheight-tighter.u-marginbottom-20", "Recompensa"), m(".fontsize-smallest.lineheight-looser", _.isEmpty(reward) ? "Apoio sem recompensa." : [ "ID: " + reward.id, m("br"), "Valor mínimo: R$" + h.formatNumber(reward.minimum_value, 2, 3), m("br"), m.trust("Disponíveis: " + available + " / " + (reward.maximum_contributions || "&infin;")), m("br"), "Aguardando confirmação: " + reward.waiting_payment_count, m("br"), "Descrição: " + reward.description ]) ]);
        }
    };
}(window.m, window.c.h, window._), window.c.AdminTransactionHistory = function(m, h, _) {
    return {
        controller: function(args) {
            var contribution = args.contribution, mapEvents = _.reduce([ {
                date: contribution.paid_at,
                name: "Apoio confirmado"
            }, {
                date: contribution.pending_refund_at,
                name: "Reembolso solicitado"
            }, {
                date: contribution.refunded_at,
                name: "Estorno realizado"
            }, {
                date: contribution.created_at,
                name: "Apoio criado"
            }, {
                date: contribution.refused_at,
                name: "Apoio cancelado"
            }, {
                date: contribution.deleted_at,
                name: "Apoio excluído"
            }, {
                date: contribution.chargeback_at,
                name: "Chargeback"
            } ], function(memo, item) {
                return null !== item.date && void 0 !== item.date ? (item.originalDate = item.date, 
                item.date = h.momentify(item.date, "DD/MM/YYYY, HH:mm"), memo.concat(item)) : memo;
            }, []);
            return {
                orderedEvents: _.sortBy(mapEvents, "originalDate")
            };
        },
        view: function(ctrl) {
            return m(".w-col.w-col-4", [ m(".fontweight-semibold.fontsize-smaller.lineheight-tighter.u-marginbottom-20", "Histórico da transação"), ctrl.orderedEvents.map(function(cEvent) {
                return m(".w-row.fontsize-smallest.lineheight-looser.date-event", [ m(".w-col.w-col-6", [ m(".fontcolor-secondary", cEvent.date) ]), m(".w-col.w-col-6", [ m("div", cEvent.name) ]) ]);
            }) ]);
        }
    };
}(window.m, window.c.h, window._), window.c.AdminTransaction = function(m, h) {
    return {
        view: function(ctrl, args) {
            var contribution = args.contribution;
            return m(".w-col.w-col-4", [ m(".fontweight-semibold.fontsize-smaller.lineheight-tighter.u-marginbottom-20", "Detalhes do apoio"), m(".fontsize-smallest.lineheight-looser", [ "Valor: R$" + h.formatNumber(contribution.value, 2, 3), m("br"), "Taxa: R$" + h.formatNumber(contribution.gateway_fee, 2, 3), m("br"), "Anônimo: " + (contribution.anonymous ? "Sim" : "Não"), m("br"), "Id pagamento: " + contribution.gateway_id, m("br"), "Apoio: " + contribution.contribution_id, m("br"), "Chave: \n", m("br"), contribution.key, m("br"), "Meio: " + contribution.gateway, m("br"), "Operadora: " + (contribution.gateway_data && contribution.gateway_data.acquirer_name), m("br"), function() {
                return contribution.is_second_slip ? [ m('a.link-hidden[href="#"]', "Boleto bancário"), " ", m("span.badge", "2a via") ] : void 0;
            }() ]) ]);
        }
    };
}(window.m, window.c.h), window.c.AdminUser = function(m) {
    return {
        view: function(ctrl, args) {
            var user = args.item, userProfile = function() {
                return user.user_profile_img || "/assets/catarse_bootstrap/user.jpg";
            };
            return m(".w-row", [ m(".w-col.w-col-3.w-col-small-3.u-marginbottom-10", [ m('img.user-avatar[src="' + userProfile() + '"]') ]), m(".w-col.w-col-9.w-col-small-9", [ m(".fontweight-semibold.fontsize-smaller.lineheight-tighter.u-marginbottom-10", [ m('a.alt-link[target="_blank"][href="/users/' + user.user_id + '/edit"]', user.user_name) ]), m(".fontsize-smallest", "Usuário: " + user.user_id), m(".fontsize-smallest.fontcolor-secondary", "Catarse: " + user.email), m(".fontsize-smallest.fontcolor-secondary", "Gateway: " + user.payer_email) ]) ]);
        }
    };
}(window.m), window.c.FilterDateRange = function(m) {
    return {
        view: function(ctrl, args) {
            return m(".w-col.w-col-3.w-col-small-6", [ m('label.fontsize-smaller[for="' + args.index + '"]', args.label), m(".w-row", [ m(".w-col.w-col-5.w-col-small-5.w-col-tiny-5", [ m('input.w-input.text-field.positive[id="' + args.index + '"][type="text"]', {
                onchange: m.withAttr("value", args.first),
                value: args.first()
            }) ]), m(".w-col.w-col-2.w-col-small-2.w-col-tiny-2", [ m(".fontsize-smaller.u-text-center.lineheight-looser", "到") ]), m(".w-col.w-col-5.w-col-small-5.w-col-tiny-5", [ m('input.w-input.text-field.positive[type="text"]', {
                onchange: m.withAttr("value", args.last),
                value: args.last()
            }) ]) ]) ]);
        }
    };
}(window.m), window.c.FilterDropdown = function(m, _) {
    return {
        view: function(ctrl, args) {
            return m(".w-col.w-col-3.w-col-small-6", [ m('label.fontsize-smaller[for="' + args.index + '"]', args.label), m('select.w-select.text-field.positive[id="' + args.index + '"]', {
                onchange: m.withAttr("value", args.vm),
                value: args.vm()
            }, [ _.map(args.options, function(data) {
                return m('option[value="' + data.value + '"]', data.option);
            }) ]) ]);
        }
    };
}(window.m, window._), window.c.FilterMain = function(m) {
    return {
        view: function(ctrl, args) {
            return m(".w-row", [ m(".w-col.w-col-10", [ m('input.w-input.text-field.positive.medium[placeholder="' + args.placeholder + '"][type="text"]', {
                onchange: m.withAttr("value", args.vm),
                value: args.vm()
            }) ]), m(".w-col.w-col-2", [ m('input#filter-btn.btn.btn-large.u-marginbottom-10[type="submit"][value="搜索"]') ]) ]);
        }
    };
}(window.m), window.c.FilterNumberRange = function(m) {
    return {
        view: function(ctrl, args) {
            return m(".w-col.w-col-3.w-col-small-6", [ m('label.fontsize-smaller[for="' + args.index + '"]', args.label), m(".w-row", [ m(".w-col.w-col-5.w-col-small-5.w-col-tiny-5", [ m('input.w-input.text-field.positive[id="' + args.index + '"][type="text"]', {
                onchange: m.withAttr("value", args.first),
                value: args.first()
            }) ]), m(".w-col.w-col-2.w-col-small-2.w-col-tiny-2", [ m(".fontsize-smaller.u-text-center.lineheight-looser", "到") ]), m(".w-col.w-col-5.w-col-small-5.w-col-tiny-5", [ m('input.w-input.text-field.positive[type="text"]', {
                onchange: m.withAttr("value", args.last),
                value: args.last()
            }) ]) ]) ]);
        }
    };
}(window.m), window.c.PaymentStatus = function(m) {
    return {
        controller: function(args) {
            var displayPaymentMethod, paymentMethodClass, stateClass, payment = args.item, card = null;
            return card = function() {
                if (payment.gateway_data) switch (payment.gateway.toLowerCase()) {
                  case "moip":
                    return {
                        first_digits: payment.gateway_data.cartao_bin,
                        last_digits: payment.gateway_data.cartao_final,
                        brand: payment.gateway_data.cartao_bandeira
                    };

                  case "pagarme":
                    return {
                        first_digits: payment.gateway_data.card_first_digits,
                        last_digits: payment.gateway_data.card_last_digits,
                        brand: payment.gateway_data.card_brand
                    };
                }
            }, displayPaymentMethod = function() {
                switch (payment.payment_method.toLowerCase()) {
                  case "boletobancario":
                    return m("span#boleto-detail", "");

                  case "cartaodecredito":
                    var cardData = card();
                    return cardData ? m("#creditcard-detail.fontsize-smallest.fontcolor-secondary.lineheight-tight", [ cardData.first_digits + "******" + cardData.last_digits, m("br"), cardData.brand + " " + payment.installments + "x" ]) : "";
                }
            }, paymentMethodClass = function() {
                switch (payment.payment_method.toLowerCase()) {
                  case "boletobancario":
                    return ".fa-barcode";

                  case "cartaodecredito":
                    return ".fa-credit-card";

                  default:
                    return ".fa-question";
                }
            }, stateClass = function() {
                switch (payment.state) {
                  case "paid":
                    return ".text-success";

                  case "refunded":
                    return ".text-refunded";

                  case "pending":
                  case "pending_refund":
                    return ".text-waiting";

                  default:
                    return ".text-error";
                }
            }, {
                displayPaymentMethod: displayPaymentMethod,
                paymentMethodClass: paymentMethodClass,
                stateClass: stateClass
            };
        },
        view: function(ctrl, args) {
            var payment = args.item;
            return m(".w-row", [ m(".fontsize-smallest.lineheight-looser.fontweight-semibold", [ m("span.fa.fa-circle" + ctrl.stateClass()), " " + payment.state ]), m(".fontsize-smallest.fontweight-semibold", [ m("span.fa" + ctrl.paymentMethodClass()), " ", m('a.link-hidden[href="#"]', payment.payment_method) ]), m(".fontsize-smallest.fontcolor-secondary.lineheight-tight", [ ctrl.displayPaymentMethod() ]) ]);
        }
    };
}(window.m), window.c.TeamMembers = function(_, m, models) {
    return {
        controller: function() {
            var vm = {
                collection: m.prop([])
            }, groupCollection = function(collection, groupTotal) {
                return _.map(_.range(Math.ceil(collection.length / groupTotal)), function(i) {
                    return collection.slice(i * groupTotal, (i + 1) * groupTotal);
                });
            };
            return models.teamMember.getPage().then(function(data) {
                vm.collection(groupCollection(data, 4));
            }), {
                vm: vm
            };
        },
        view: function(ctrl) {
            return m("#team-members-static.w-section.section", [ m(".w-container", [ _.map(ctrl.vm.collection(), function(group) {
                return m(".w-row.u-text-center", [ _.map(group, function(member) {
                    return m(".team-member.w-col.w-col-3.w-col-small-3.w-col-tiny-6.u-marginbottom-40", [ m('a.alt-link[href="/users/' + member.id + '"]', [ m('img.thumb.big.u-round.u-marginbottom-10[src="' + member.img + '"]'), m(".fontweight-semibold.fontsize-base", member.name) ]), m(".fontsize-smallest.fontcolor-secondary", "Apoiou " + member.total_contributed_projects + " projetos") ]);
                }) ]);
            }) ]) ]);
        }
    };
}(window._, window.m, window.c.models), window.c.TeamTotal = function(m, h, models) {
    return {
        controller: function() {
            var vm = {
                collection: m.prop([])
            };
            return models.teamTotal.getRow().then(function(data) {
                vm.collection(data);
            }), {
                vm: vm
            };
        },
        view: function(ctrl) {
            return m("#team-total-static.w-section.section-one-column.u-margintop-40.u-text-center.u-marginbottom-20", [ ctrl.vm.collection().map(function(teamTotal) {
                return m(".w-container", [ m(".w-row", [ m(".w-col.w-col-2"), m(".w-col.w-col-8", [ m(".fontsize-base.u-marginbottom-30", "Hoje somos " + teamTotal.member_count + " pessoas espalhadas por " + teamTotal.total_cities + " cidades em " + teamTotal.countries.length + " países (" + teamTotal.countries.toString() + ")! O Catarse é independente, sem investidores, de código aberto e construído com amor. Nossa paixão é construir um ambiente onde cada vez mais projetos possam ganhar vida."), m(".fontsize-larger.lineheight-tight.text-success", "Nossa equipe, junta, já apoiou R$" + h.formatNumber(teamTotal.total_amount) + " para " + teamTotal.total_contributed_projects + " projetos!") ]), m(".w-col.w-col-2") ]) ]);
            }) ]);
        }
    };
}(window.m, window.c.h, window.c.models), window.c.ToggleDiv = function(m, h) {
    return {
        toggler: function() {
            return h.toggleProp("none", "block");
        },
        controller: function(args) {
            return {
                vm: {
                    display: args.display
                }
            };
        },
        view: function(ctrl, args) {
            return m(".toggleDiv", {
                style: {
                    transition: "all .1s ease-out",
                    overflow: "hidden",
                    display: ctrl.vm.display()
                }
            }, [ args.content ]);
        }
    };
}(window.m, window.c.h), window.c.pages.Team = function(m, c) {
    return {
        view: function() {
            return m("#static-team-app", [ m.component(c.TeamTotal), m.component(c.TeamMembers) ]);
        }
    };
}(window.m, window.c);