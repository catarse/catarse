import Stream from 'mithril/stream'

export interface ViewModel<T> {
    collection: Stream<T[]>
    isLastPage() : boolean;
    total() : number;
    isLoading() : boolean;
    firstPage(parameters: Object) : Promise<T[]>;
    nextPage() : Promise<T[]>;
}