export interface ViewModel<T> {
    collection(data?: T[]) : T[];
    isLastPage() : boolean;
    total() : number;
    isLoading() : boolean;
    firstPage(parameters: Object) : Promise<T[]>;
    nextPage() : Promise<T[]>;
}