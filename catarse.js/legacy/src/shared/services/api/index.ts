import { FilterPostgrestApi } from './implementation/filter-postgrest-api'
export { Filter } from './filter'
import { catarse } from '../../../api'
import { Filter } from './filter'

export { 
    LessThan,
    LessThanOrEqual,
    GreaterThan,
    GreaterThanOrEqual,
    Equal,
    Not,
} from './implementation/filter-postgrest-api'

export function filterFactory() : Filter {
    return new FilterPostgrestApi(catarse)
}