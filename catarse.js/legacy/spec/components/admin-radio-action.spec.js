import mq from 'mithril-query';
import m from 'mithril';
import prop from 'mithril/stream';
import {catarse} from '../../src/api';
import adminRadioAction from '../../src/c/admin-radio-action';

describe('AdminRadioAction', () => {
    const testModel = catarse.model('reward_details'),
        testStr = 'updated',
        errorStr = 'error!';

    let error = false,
        item,
        fakeData = {},
        $output;

    let args = {
        getKey: 'project_id',
        updateKey: 'contribution_id',
        selectKey: 'reward_id',
        radios: 'rewards',
        callToAction: 'Alterar Recompensa',
        outerLabel: 'Recompensa',
        getModel: testModel,
        updateModel: testModel,
        validate: () => {
            return undefined;
        }
    };

    let errorArgs = _.extend({}, args, {
        validate: () => {
            return errorStr;
        }
    });

    describe('view', () => {
        beforeAll(() => {
            item = _.first(RewardDetailsMockery());
            args.selectedItem = prop(item);
            $output = mq(adminRadioAction, {
                data: args,
                item: prop(item),
                radios: [{id: 'id', description: 'description'}],
                getKeyValue: () => {},
                updateKeyValue: () => {},
            });
        });

        it('shoud only render the outerLabel on first render', () => {
            expect($output.contains(args.outerLabel)).toBeTrue();
            expect($output.contains(args.callToAction)).toBeFalse();
        });

        describe('on action button click', () => {
            beforeAll(() => {
                $output.click('button');
                
            });

            it('should render a row of radio inputs', () => {
                const lastRequest = jasmine.Ajax.requests.mostRecent();
                expect($output.find('input[type="radio"]').length).toEqual(JSON.parse(lastRequest.responseText).length);
            });

            it('should render the description of the default selected radio', () => {
                $output.should.contain(item.description);
            });

            it('should send an patch request on form submit', () => {
                $output.click('#r-0');
                $output.trigger('form', 'onsubmit');

                const lastRequest = jasmine.Ajax.requests.mostRecent();
                // Should make a patch request to update item
                expect(lastRequest.method).toEqual('PATCH');
                pending();
            });

            describe('when new value is not valid', () => {
                beforeAll(() => {
                    $output = mq(adminRadioAction, {
                        data: errorArgs,
                        item: prop(item),
                        radios: [{id:item.id}]
                    });
                    $output.click('button');
                    $output.click('#r-0');

                });

                it('should present an error message when new value is invalid', () => {
                    $output.trigger('form', 'onsubmit');
                    $output.should.contain(errorStr);
                });
            });
        });
    });
});
