import { Equal, Filter } from '../../../../../src/shared/services'
import { FilterPostgrestApi } from '../../../../../src/shared/services/api/implementation/filter-postgrest-api'

describe('FilterPostgrestApi', () => {
    const values = {}
    const mockFiltersVM = {
        filtersVM(fields : { [field:string] : string }) {
            Object.keys(fields).forEach(field => {
                mockFiltersVM[field] = (value : string | number) => {
                    values[field] = `${fields[field]}.${value}`
                    return mockFiltersVM
                }
            })
            return mockFiltersVM
        },
        parameters() {
            return { ...values }
        }
    }

    it('should build params set', () => {
        // 1. Arrange
        const filter : Filter = new FilterPostgrestApi(mockFiltersVM)

        // 2. Act
        filter.setParam('test_param', Equal('value'))

        // 3. Assert
        expect(filter.toParameters()).toEqual(jasmine.objectContaining({
            test_param: 'eq.value'
        }))
    })
})