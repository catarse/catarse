import { Stream } from 'mithril/stream'

export interface Pagination<DataType> {
    collection: Stream<DataType[]>
    firstPage(parameters?: any): void
    isLastPage(): boolean​
    isLoading: Stream<boolean>
    nextPage(): void
    resultsCount: Stream<number>
    total: Stream<number>
}
