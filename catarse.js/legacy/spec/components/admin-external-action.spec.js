import mq from 'mithril-query';
import models from '../../src/models';
import adminExternalAction from '../../src/c/admin-external-action';
import {catarse} from '../../src/api';

describe('adminExternalAction', () => {
    var testModel = catarse.model('reloadAction'),
        item = {
            testKey: 'foo'
        },
        ctrl, $output;

    var args = {
        updateKey: 'updateKey',
        callToAction: 'cta',
        innerLabel: 'inner',
        outerLabel: 'outer',
        model: testModel,
        requestOptions: {
            url: 'http://external_api'
        }
    };

    describe('view', () => {
        beforeAll(() => {
            jasmine.Ajax.stubRequest(args.requestOptions.url).andReturn({
                'responseText': JSON.stringify([])
            });
        });

        beforeEach(() => {
            $output = mq(adminExternalAction, {
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

            it('should render a call to action', () => {
                expect($output.first('input[type="submit"]').attrs.value).toEqual(args.callToAction);
            });

        });

        describe('on form submit', () => {
            beforeEach(() => {
                $output.click('button');
            });

            it('should call a submit function on form submit', () => {
                // $output.trigger('form.w-form', 'submit');
                // const lastRequest = jasmine.Ajax.requests.mostRecent();
                // expect(lastRequest.url).toEqual('https://api.catarse.me/reloadAction');
            });
        });
    });
});
