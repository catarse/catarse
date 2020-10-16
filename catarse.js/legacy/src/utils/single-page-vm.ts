import { ViewModel } from "../@types/view-model";

export class SinglePageViewModel<T> implements ViewModel<T> {
    
    private _data : T[]
    private _isLoading : boolean
    private _total : number

    constructor(getCollection : () => Promise<T[]>) {

        this._data = []
        this._isLoading = true
        this._total = 0

        getCollection().then(retrievedData => {
            this._data = retrievedData
            this._isLoading = false
            this._total = this._data.length
        })
    }

    collection(data?: T[]): T[] {
        return this._data
    }
    
    isLastPage(): boolean {
        return true
    }

    total(): number {
        return this._total
    }

    isLoading(): boolean {
        return this._isLoading
    }
    
    async firstPage(parameters: Object): Promise<T[]> {
        return this._data
    }

    async nextPage(): Promise<T[]> {
        return []
    }

}