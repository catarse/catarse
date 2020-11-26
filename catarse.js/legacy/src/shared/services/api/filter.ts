export interface Filter {
    setParam(field : string, op : Operator) : Filter
    toParameters() : { [field:string] : string }
}

export interface Operator { 
    operator: string
    value: NativeValueType
}
export type LessThan = (value : NativeValueType) => Operator
export type Less = (value : NativeValueType) => Operator
export type GreaterThan = (value : NativeValueType) => Operator
export type Greater = (value : NativeValueType) => Operator
export type Equal = (value : NativeValueType) => Operator
export type Not = (value : NativeValueType) => Operator

export type NativeValueType = number | string | object | JSON