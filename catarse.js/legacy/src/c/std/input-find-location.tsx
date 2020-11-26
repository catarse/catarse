import m from 'mithril'
import { City } from '../../entities/city'
import { searchCities, getCityById } from '../../vms/cities-search-vm'
import h from '../../h'

export type InputFindLocationAttrs = {
    city_id?: number
    class: string
    onSelect(city : City): void
}

export type InputFindLocationState = {
    searchCities(input : string): void
    cities: City[]
    selectedCity?: City
    onSelect(city : City): void
    cityInputValue: string
}

export class InputFindLocation implements m.Component {
    
    oninit({ attrs, state } : m.Vnode<InputFindLocationAttrs, InputFindLocationState>) {

        if (attrs.city_id) {
            getCityById(attrs.city_id).then(city => {
                state.selectedCity = city
                state.cityInputValue = state.selectedCity && `${state.selectedCity.name} - ${state.selectedCity.state_name}`
                h.redraw()
            })
        }
        state.selectedCity = null
        state.cityInputValue = ''
        state.cities = []
        state.searchCities = async (inputText) => {
            try {
                state.cityInputValue = inputText
                state.cities = await searchCities(inputText)
            } catch(e) {
                state.cities = []
            }

            h.redraw()
        }
        state.onSelect = (city) => {
            state.selectedCity = city
            state.cityInputValue = state.selectedCity && `${state.selectedCity.name} - ${state.selectedCity.state_name}`
            attrs.onSelect(city)
            state.cities = []
            h.redraw()
        }
    }

    view({ attrs, state } : m.Vnode<InputFindLocationAttrs, InputFindLocationState>) {
        const cities = state.cities
        const searchCities = state.searchCities
        const hasCitiesToDisplay = cities && cities.length > 0
        const onSelect = state.onSelect
        const cityInputValue = state.cityInputValue

        return (
            <>
                <input 
                    value={cityInputValue} 
                    oninput={(event : Event) => searchCities(event.target.value)} 
                    type='text' 
                    class={`text-field positive w-input ${attrs.class}`}
                    maxlength='256' 
                    required />
                {
                    hasCitiesToDisplay &&
                    <div class='table-outer search-pre-result' style='z-index: 9999;' >
                        {
                            cities.map(city => (
                                <div class='table-row fontsize-smallest fontcolor-secondary'>
                                    <div onclick={() => onSelect(city)} class='city-select fontsize-smallest link-hidden-light'>
                                        {city.name} - {city.state_name}
                                    </div>
                                </div>
                            ))
                        }
                    </div>
                }
            </>
        )
    }
}