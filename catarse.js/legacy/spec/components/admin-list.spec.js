import mq from 'mithril-query';
import m from 'mithril';
import prop from 'mithril/stream';
import {catarse} from '../../src/api';
import adminList from '../../src/c/admin-list';

describe('adminList', () => {
    let $output, model, vm, ListItemMock, ListDetailMock,
        results = [{
            id: 1
        }],
        listParameters, endpoint;

    beforeAll(() => {
        endpoint = mockEndpoint('items', results);

        ListItemMock = {
            view: function(ctrl, args) {
                return m('.list-item-mock');
            }
        };
        ListDetailMock = {
            view: function(ctrl, args) {
                return m('');
            }
        };
        model = catarse.model('items');
        vm = {
            list: catarse.paginationVM(model),
            error: prop()
        };
        listParameters = {
            vm: vm,
            listItem: ListItemMock,
            listDetail: ListDetailMock
        };
    });

    describe('view', () => {
        describe('when not loading', () => {
            beforeEach(() => {
                spyOn(vm.list, "isLoading").and.returnValue(false);
                $output = mq(
                    adminList,
                    listParameters
                );
            });

            it('should render fetched items', () => {
                setTimeout(() => {
                    expect($output.find('.card').length).toEqual(results.length);
                }, 200);                
            });

            it('should not show a loading icon', () => {
                $output.should.not.have('img[alt="Loader"]');
            });
        });

        describe('when loading', () => {
            beforeEach(() => {
                spyOn(vm.list, "isLoading").and.returnValue(true);
                $output = mq(
                    adminList,
                    listParameters
                );
            });

            it('should render fetched items', () => {
                expect($output.find('.card').length).toEqual(results.length);
            });

            it('should show a loading icon', () => {
                $output.should.have('img[alt="Loader"]');
            });
        });

        describe('when error', () => {
            beforeEach(() => {
                vm.error('endpoint error');
                $output = mq(
                    adminList,
                    listParameters
                );
            });

            it('should show an error info', () => {
                expect($output.has('.card-error')).toBeTrue();
            });
        });
    });
});
