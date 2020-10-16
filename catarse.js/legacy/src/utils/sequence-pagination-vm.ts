import { ViewModel } from '../vms/projects-explore-vm';

export interface Model {
    pageSize(newSize? : number) : number;

}

export class SequencePaginationVM<T> implements ViewModel<T> {

    private vms : ViewModel<T>[];
    private pageSize : number;
    private model : Model;

    constructor(vms : ViewModel<T>[], pageSize : number = 9, model : Model) {
        this.vms = vms;
        this.pageSize = pageSize;
        this.model = model;
    }

    firstPage(parameters: Object): Promise<T[]> {
        throw new Error("Method not implemented.");
    }

    collection() : T[] {
        let collectionData : T[] = [];

        for (let vmIndex = 0; vmIndex < this.vms.length; vmIndex += 1) {
            
            const vm = this.vms[vmIndex];
            const isLastPage = vm.collection().length >= vm.total();

            if (isLastPage) {
                collectionData = collectionData.concat(vm.collection());
            } else {
                return collectionData.concat(vm.collection());
            }
        }

        return collectionData;
    }

    isLastPage() : boolean {
        let isLastPage = true;

        for (let vmIndex = 0; vmIndex < this.vms.length; vmIndex += 1) {
            const vm = this.vms[vmIndex];
            const isLastPageFromVM = vm.collection().length >= vm.total();
            isLastPage = isLastPage && isLastPageFromVM;
            if (!isLastPage) {
                return isLastPage;
            }
        }

        return isLastPage;
    }

    isLoading() : boolean {
        let isLoading = false;

        for (let vmIndex = 0; vmIndex < this.vms.length; vmIndex += 1) {
            const vm = this.vms[vmIndex];
            isLoading = isLoading || vm.isLoading();
        }

        return isLoading;
    }

    nextPage() : Promise<T[]> {
        for (let vmIndex = 0; vmIndex < this.vms.length; vmIndex += 1) {
            const vm = this.vms[vmIndex];
            const isLastPage = vm.collection().length >= vm.total();
            if (!isLastPage) {
                this.model.pageSize(this.pageSize);
                return vm.nextPage();
            }
        }
    }

    total() : number {
        let total = 0;

        for (let vmIndex = 0; vmIndex < this.vms.length; vmIndex += 1) {
            const vm = this.vms[vmIndex];
            total = total + vm.total();
        }

        return total;
    }
}