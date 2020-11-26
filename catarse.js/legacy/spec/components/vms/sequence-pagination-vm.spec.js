import { SequencePaginationVM } from "../../../src/utils/sequence-pagination-vm";
import _ from 'underscore';

describe('SequencePaginationVM', () => {

    const vm1 = {
        collection() {
            return [{data: 1}];
        },
        isLoading() {
            return false;
        },
        isLastPage() {
            return true;
        },
        nextPage() {
        },
        total() {
            return 0;
        }
    };

    const vm2 = {
        collection() {
            return [{data: 2}];
        },
        isLoading() {
            return false;
        },
        isLastPage() {
            return true;
        },
        nextPage() {
        },
        total() {
            return 0;
        }
    };

    const model = {
        pageSize(size) {

        }
    };

    it('should use 2 view models and collection for the first vm', () => {

        const sequencePaginationVM = new SequencePaginationVM([vm1, vm2], 9, model);

        const isEqual = _.isEqual(sequencePaginationVM.collection(), vm1.collection().concat(vm2.collection()))

        expect(isEqual).toBeTrue();
    });

    it('should click next page on first vm', (done) => {
        vm1.total = () => 5;
        vm1.collection = () => [1, 2];
        vm1.isLastPage = () => false;
        vm1.nextPage = () => done();
        const sequencePaginationVM = new SequencePaginationVM([vm1, vm2], 9, model);
        sequencePaginationVM.nextPage();
    });

    it('should click next page on second vm', (done) => {
        vm1.total = () => 2;
        vm1.collection = () => [1, 2];
        vm1.isLastPage = () => true;
        vm1.nextPage = () => {};

        vm2.total = () => 5;
        vm2.collection = () => [1, 2];
        vm2.isLastPage = () => false;
        vm2.nextPage = () => done();
        const sequencePaginationVM = new SequencePaginationVM([vm1, vm2], 9, model);
        sequencePaginationVM.nextPage();
    });

    it('should have total equal to total of both vms', () => {
        vm1.total = () => 2;
        vm1.collection = () => [1, 2];
        vm1.isLastPage = () => true;

        vm2.total = () => 2;
        vm2.collection = () => [1, 2];
        vm2.isLastPage = () => false;
        const sequencePaginationVM = new SequencePaginationVM([vm1, vm2], 9, model);
        expect(sequencePaginationVM.total()).toBe(4);
    });
});