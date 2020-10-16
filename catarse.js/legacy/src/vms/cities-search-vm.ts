import _ from 'underscore'
import { catarse } from '../api'
import models from '../models'
import { City } from '../@types/city'
import { State } from '../@types/state'
import { CityState } from '../@types/city-state'

type ExtendedWindow = {
    replaceDiacritics(inputText : string): string;
}

const { replaceDiacritics } = window as any as ExtendedWindow;

export async function searchCitiesGroupedByState(inputText: string) : Promise<CityState[]> {

    const cities = await searchCities(inputText);
    const cityGroup : { [key:string] : City[] } = {};

    for (let city of cities) {
        cityGroup[city.state_name] = [city].concat(cityGroup[city.state_name] || []);
    }

    return cityGroupToList(cityGroup);
}

export async function searchCities(inputText : string) : Promise<City[]> {
    
    const filters = catarse.filtersVM({
        explore_search_index: 'or'
    }).order({ name: 'asc' })

    const searchTextWithoutDiacritics = replaceDiacritics(inputText)

    filters.explore_search_index({
        state_name: {
            'ilike': `*${searchTextWithoutDiacritics}*`
        },
        search_index:  {
            'ilike': `*${searchTextWithoutDiacritics}*`
        }
    })

    return await models.city.getPage(filters.parameters())
}

export async function getCityById(city_id : number) : Promise<City> {
    const filters = catarse.filtersVM({
        id: 'eq'
    }).id(city_id)

    return _.first(await models.city.getPage(filters.parameters()));
}

export function cityGroupToList(citiesByStateOnKey: {[key:string] : City[]}) : CityState[] {
    
    const cityList : CityState[] = [];

    for (const stateName of Object.keys(citiesByStateOnKey)) {
        const cities = citiesByStateOnKey[stateName];
        const firstCity = cities[0];
        const cityState : CityState = {
            state: {
                acronym: firstCity.acronym, 
                state_name: stateName
            }
        };

        cityList.push(cityState);

        for (const city of cities) {
            const cityState : CityState = {
                state: {
                    acronym: firstCity.acronym, 
                    state_name: stateName
                },
                city,
            };
            cityList.push(cityState);
        }
    }

    return cityList;
}