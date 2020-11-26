export type StreamType<T> = (newData? : T) => T
export type ToggleStream<T> = StreamType<T> & {
    toggle(): void
}

export type RewardDetailsStream = {
    id(newData? : number): number
    minimum_value(newData? : number): number
    title(newData? : string): string
    shipping_options(newData? : string): string
    edit: ToggleStream<boolean>
    deliver_at(newData? : string): string
    description(newData? : string): string
    paid_count(newData? : number): number
    waiting_payment_count(newData? : number): number
    limited: ToggleStream<boolean>
    maximum_contributions(newData? : number): any
    run_out: ToggleStream<boolean>
    newReward: boolean
    uploaded_image(newData? : string): string
    row_order(newData? : number): number
}