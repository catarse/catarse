import m from 'mithril';
import prop from 'mithril/stream';
import _ from 'underscore';
import { catarse } from '../api';
import projectListVM from '../vms/project-list-vm';
import models from '../models';
import projectFilterVM from '../vms/project-filter-vm';
import adminFilter from '../c/admin-filter';
import adminList from '../c/admin-list';
import adminProjectItem from '../c/admin-project-item';
import adminProjectDetail from '../c/admin-project-detail';
import filterDateRange from '../c/filter-date-range';
import filterNumberRange from '../c/filter-number-range';
import filterMain from '../c/filter-main';
import filterDropdown from '../c/filter-dropdown';

const adminProjects = {
    oninit: function(vnode) {
        const listVM = projectListVM,
            filterVM = projectFilterVM,
            categories = prop([]),
            filters = catarse.filtersVM,
            error = prop(''),
            filterBuilder = [{ // name
                component: filterMain,
                data: {
                    vm: filterVM.full_text_index,
                    placeholder: 'Busque por projeto, permalink, email, nome do realizador...',
                },
            }, { // status
                component: filterDropdown,
                data: {
                    label: 'Com o estado',
                    index: 'state',
                    name: 'state',
                    vm: filterVM.state,
                    options: [{
                        value: '',
                        option: 'Qualquer um'
                    }, {
                        value: 'successful',
                        option: 'successful'
                    }, {
                        value: 'waiting_funds',
                        option: 'waiting_funds'
                    }, {
                        value: 'online',
                        option: 'online'
                    }, {
                        value: 'failed',
                        option: 'failed'
                    }, {
                        value: 'draft',
                        option: 'draft'
                    }]
                }
            },
            { // mode
                component: filterDropdown,
                data: {
                    label: 'Modalidade',
                    index: 'mode',
                    name: 'mode',
                    vm: filterVM.mode,
                    options: [{
                        value: '',
                        option: 'Qualquer um'
                    }, {
                        value: 'aon',
                        option: 'Tudo ou nada'
                    }, {
                        value: 'flex',
                        option: 'Flex'
                    }, {
                        value: 'sub',
                        option: 'Recorrente'
                    }
                    ]
                }
            },
            { // recommended
                component: filterDropdown,
                data: {
                    label: 'Recomendado',
                    index: 'recommended',
                    name: 'recommended',
                    vm: filterVM.recommended,
                    options: [{
                        value: '',
                        option: 'Qualquer um'
                    }, {
                        value: true,
                        option: 'Sim'
                    }, {
                        value: false,
                        option: 'Não'
                    }
                    ]
                }
            }, { // goal
                component: filterNumberRange,
                data: {
                    label: 'Meta entre',
                    first: filterVM.goal.gte,
                    last: filterVM.goal.lte
                }
            },
            { // progress
                component: filterNumberRange,
                data: {
                    label: 'Progresso % entre',
                    first: filterVM.progress.gte,
                    last: filterVM.progress.lte
                }
            },
            { // updated at
                component: filterDateRange,
                data: {
                    label: 'Atualizado entre',
                    first: filterVM.updated_at.gte,
                    last: filterVM.updated_at.lte
                }
            },
            { // expires_at
                component: filterDateRange,
                data: {
                    label: 'Expira entre',
                    first: filterVM.project_expires_at.gte,
                    last: filterVM.project_expires_at.lte
                }
            },
            { // created_at
                component: filterDateRange,
                data: {
                    label: 'Criado entre',
                    first: filterVM.created_at.gte,
                    last: filterVM.created_at.lte
                }
            }
            ],
            loadCategories = () => models.category.getPage(filters({}).order({
                name: 'asc'
            }).parameters()).then((data) => {
                categories(data);
                const options = _.map(categories(), category => ({ value: category.name, option: category.name }));
                options.unshift({ value: '', option: 'Qualquer uma' });
                filterBuilder.unshift(
                    { // category
                        component: filterDropdown,
                        data: {
                            label: 'Categoria',
                            index: 'category',
                            name: 'category_name',
                            vm: filterVM.category_name,
                            options
                        }
                    }
              );
            }),
            submit = () => {
                listVM.firstPage(filterVM.parameters()).then(_ => m.redraw(), (serverError) => {
                    error(serverError.message);
                    m.redraw();
                });
                return false;
            };

        loadCategories();

        vnode.state = {
            filterVM,
            filterBuilder,
            listVM: {
                list: listVM,
                error
            },
            submit
        };
    },
    view: function({state}) {
        const label = 'Projetos';

        return m('', [
            m(adminFilter, {
                form: state.filterVM.formDescriber,
                filterBuilder: state.filterBuilder,
                label,
                submit: state.submit
            }),
            m(adminList, {
                vm: state.listVM,
                filterVM: state.filterVM,
                label,
                listItem: adminProjectItem,
                listDetail: adminProjectDetail
            })
        ]);
    }
};

export default adminProjects;
