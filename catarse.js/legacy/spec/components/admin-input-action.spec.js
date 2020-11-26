import mq from 'mithril-query';
import m from 'mithril';
import {catarse} from '../../src/api';
import adminInputAction from '../../src/c/admin-input-action';

describe('adminInputAction', () => {
    let testModel = catarse.model('test'),
        item = {
            testKey: 'foo'
        },
        forced = 'value',
        ctrl, $output;

    let args = {
        property: 'testKey',
        updateKey: 'updateKey',
        callToAction: 'cta',
        innerLabel: 'inner',
        outerLabel: 'outer',
        placeholder: 'place',
        model: testModel
    };

    describe('controller', () => {
        beforeAll(() => {
            ctrl = mq(adminInputAction, {
                data: args,
                item: item
            });
        });

        it('should instantiate a submit function', () => {
            expect(ctrl.vnode.state.submit).toBeFunction();
        });
        it('should return a toggler prop', () => {
            expect(ctrl.vnode.state.toggler).toBeFunction();
        });
        it('should return a value property to bind to', () => {
            expect(ctrl.vnode.state.newValue).toBeFunction();
        });

        describe('when forceValue is set', () => {
            let instanceComponent;

            beforeAll(() => {
                args = args || {};
                args.forceValue = forced;
                
                instanceComponent = mq(m(adminInputAction, {
                    data: args,
                    item: item
                }));
            });

            it('should initialize newValue with forced value', () => {
                instanceComponent.click('button');
                instanceComponent.redraw();
                expect(instanceComponent.should.not.contain(forced)).toBeTrue();
            });

            afterAll(() => {
                delete args.forceValue;
            });
        });

    });

    describe('view', () => {
        beforeEach(() => {
            $output = mq(adminInputAction, {
                data: args,
                item: item
            });
        });

        it('shoud render the outerLabel on first render', () => {
            expect($output.contains(args.outerLabel)).toBeTrue();
            expect($output.contains(args.innerLabel)).toBeFalse();
            expect($output.contains(args.placeholder)).toBeFalse();
            expect($output.contains(args.callToAction)).toBeFalse();
        });

        describe('on button click', () => {
            beforeEach(() => {
                $output.click('button');
            });

            it('should render an inner label', () => {
                expect($output.contains(args.innerLabel)).toBeTrue();
            });
            it('should render a placeholder', () => {
                expect($output.has('input[placeholder="' + args.placeholder + '"]')).toBeTrue();
            });
            it('should render a call to action', () => {
                expect($output.first('input[type="submit"]').attrs.value).toEqual(args.callToAction);
            });

            describe('when forceValue is set', () => {
                beforeAll(() => {
                    args.forceValue = forced;
                    ctrl = mq(adminInputAction, {
                        data: args,
                        item: item
                    });
                });

                it('should initialize newValue with forced value', () => {
                    expect(ctrl.vnode.state.newValue()).toEqual(forced);
                });

                afterAll(() => {
                    delete args.forceValue;
                });
            });
        });

        describe('on form submit', () => {
            beforeAll(() => {
                // spyOn($output.vnode.state, 'submit')
                //     .and
                //     .andCallThrough();
                // $output.click('button');
                // $output.trigger('form.w-form', 'onsubmit');
            });
            
            it('should call a submit function on form submit', () => {
                // expect($output.vnode.state.submit).toHaveBeenCalled();
            });
        });
    });
});
