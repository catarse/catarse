import { Filter, Operator, NativeValueType } from '../filter'

export type FiltersFactory = {
    filtersVM(params : { [field:string] : string })
}

export class FilterPostgrestApi implements Filter {
    
    private fieldsFilter : { [field:string] : Operator }

    constructor(private filtersFactory : FiltersFactory) {
        this.fieldsFilter = {}
    }

    setParam(field : string, op : Operator) : Filter {
        this.fieldsFilter[field] = op
        return this
    }

    toParameters() {
        const fields = Object.keys(this.fieldsFilter)
        const fieldsOperators : { [field:string] : string } = {}

        for (const field of fields) {
            fieldsOperators[field] = this.fieldsFilter[field].operator
        }

        const filtersVM = this.filtersFactory.filtersVM(fieldsOperators)

        for (const field of fields) {
            filtersVM[field](this.fieldsFilter[field].value)
        }

        return filtersVM.parameters()
    }
}

export class OperatorPostgrestApi implements Operator {
    constructor(private op : string, private val : NativeValueType) { }

    get operator() {
        return this.op
    }

    get value() {
        return this.val
    }
}

export const LessThan = (value : NativeValueType) : Operator => {
    return new OperatorPostgrestApi('lt', value)
}

export const LessThanOrEqual = (value : NativeValueType) : Operator => {
    return new OperatorPostgrestApi('lte', value)
}

export const GreaterThan = (value : NativeValueType) : Operator => {
    return new OperatorPostgrestApi('gt', value)
}

export const GreaterThanOrEqual = (value : NativeValueType) : Operator => {
    return new OperatorPostgrestApi('gte', value)
}

export const Equal = (value : NativeValueType) : Operator => {
    return new OperatorPostgrestApi('eq', value)
}

export const Not = (value : NativeValueType | Operator) : Operator => {
    const innerOperator = value['operator']
    const innerValue = value['value']
    if (innerOperator) {
        return new OperatorPostgrestApi(`not.${innerOperator}`, innerValue)
    } else {
        return new OperatorPostgrestApi('not', value)
    }
}