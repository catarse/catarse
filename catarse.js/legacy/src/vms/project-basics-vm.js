import m from 'mithril';
import prop from 'mithril/stream';
import _ from 'underscore';
import models from '../models';
import { catarse } from '../api';
import projectVM from './project-vm';
import h from '../h';
import generateErrorInstance from '../error';

const { replaceDiacritics } = window;

const e = generateErrorInstance();

const fields = {
    tracker_snippet_html: prop(''),
    user_id: prop(''),
    public_tags: prop(''),
    admin_tags: prop(''),
    service_fee: prop(''),
    name: prop(''),
    content_rating: prop(null),
    permalink: prop(''),
    category_id: prop(''),
    city_id: prop(''),
    city_name: prop(''),
    show_cans_and_cants: h.toggleProp(false, true),
    force_show_cans_and_cants: h.toggleProp(false, true),
    solidarity: h.RedrawStream(null),
    is_solidarity: h.RedrawStream(false),
};

const fillFields = (data) => {
    fields.tracker_snippet_html(data.tracker_snippet_html || '');
    fields.user_id(data.user_id);
    fields.admin_tags(data.admin_tag_list || '');
    fields.public_tags(data.tag_list || '');
    fields.service_fee(data.service_fee);
    fields.name(data.name);
    fields.content_rating(data.content_rating);
    fields.permalink(data.permalink);
    fields.category_id(data.category_id);
    fields.city_id(data.city_id || '');
    fields.show_cans_and_cants(data.content_rating === 18);
    if (data.address.city) {
        fields.city_name(`${data.address.city} - ${data.address.state}`);
    }
    const projectSolidarityIntegration = (data.integrations || []).find(integration => integration.name === 'SOLIDARITY_SERVICE_FEE');
    fields.solidarity(!!projectSolidarityIntegration ? projectSolidarityIntegration : null);
    fields.is_solidarity(!!projectSolidarityIntegration);
};

const updateProject = async (project_id) => {
    const projectData = {
        tracker_snippet_html: fields.tracker_snippet_html(),
        user_id: fields.user_id(),
        all_tags: fields.admin_tags(),
        all_public_tags: fields.public_tags(),
        service_fee: fields.service_fee(),
        name: fields.name(),
        content_rating: fields.content_rating(),
        permalink: fields.permalink(),
        category_id: fields.category_id(),
        city_id: fields.city_id,
    };
    
    if (fields.solidarity() && !fields.is_solidarity()) {
        projectData.integrations_attributes = [
            {
                id: fields.solidarity().id,
                name: 'SOLIDARITY_SERVICE_FEE',
                _destroy: true
            }
        ];
    
    } else if (!fields.solidarity() && fields.is_solidarity()) {
        projectData.integrations_attributes = [
            { 
                name: 'SOLIDARITY_SERVICE_FEE',
                data: {
                    name: 'COVID-19'
                }
            }
        ];
    }

    return projectVM.updateProject(project_id, projectData);
};

const loadCategoriesOptionsTo = (prop, selected) => {
    const filters = catarse.filtersVM;
    models.category.getPage(filters({}).order({
        name: 'asc'
    }).parameters()).then((data) => {
        const mapped = _.map(data, (item, index) => m(`option[value='${item.id}']`, {
            selected: selected == item.id
        }, item.name));

        prop(mapped);
    });
};

const generateSearchCity = (prop) => {
    const filters = catarse.filtersVM({
        search_index: 'ilike'
    }).order({ name: 'asc' });

    const genSelectClickCity = (city, citiesProp) => () => {
        fields.city_name(`${city.name} - ${city.acronym}`);
        fields.city_id(city.id);
        citiesProp('');
    };

    return (event) => {
        const value = event.currentTarget.value;
        filters.search_index(replaceDiacritics(value));
        fields.city_name(value);

        models.city.getPage(filters.parameters()).then((data) => {
            const map = _.map(data, item => m('.table-row.fontsize-smallest.fontcolor-secondary', [
                m('.city-select.fontsize-smallest.link-hidden-light', {
                    onclick: genSelectClickCity(item, prop)
                }, `${item.name} - ${item.acronym}`)
            ]));

            prop(m('.table-outer.search-pre-result', { style: { 'z-index': 9999 } }, map));
        }).catch((err) => {
            prop('');
        });
    };
};


const projectBasicsVM = {
    fields,
    fillFields,
    updateProject,
    loadCategoriesOptionsTo,
    e,
    generateSearchCity
};

export default projectBasicsVM;
