import m from 'mithril';
import mq from 'mithril-query';
import mr from 'mithril-node-render';
import { ExploreFilterSelect, ExploreFilterAttrs } from '../../src/c/explore/explore-filter-select';

describe('ExploreFilterSelect', () => {

    describe('view', () => {

        describe('single column', () => {
            const values = [
                {
                    label: 'First Name',
                    value: 'first_value'
                },
                {
                    label: 'Second Name',
                    value: 'second_value'
                },
            ];
    
            let currentValue = values[0];
    
            /** @type {ExploreFilterAttrs} */
            const attrs = {
                values,
                isSelected: (item) => item.value === currentValue.value,
                itemToString: (item) => item.label,
                selectedItem: () => currentValue,
                mobileLabel: 'MOBILE_LABEL',
                onSelect: (item) => currentValue = item,
                splitNumberColumns: 1,
            };
    
            let component = null;
            let rawComponent = null;
    
            beforeEach(() => {
                rawComponent = m(ExploreFilterSelect, attrs);
                component = mq(rawComponent);
            });
    
            it('should init diplaying first label', () => {
                component.should.have('.explore-span-filter-name > .inline-block');
                component.should.contain(values[0].label);
            });
            
            it('should display the selection of values', () => {
                const event = new Event('click');
                component.click('.explore-span-filter', event);
                component.should.have(`a.explore-filter-link:contains("${values[0].label}")`);
            });
    
            it('should select other values', () => {
                component.click('.explore-span-filter', new Event('click'));
                component.click(`a.explore-filter-link:contains("${values[1].label}")`, new Event('click'));
                component.should.have(`.inline-block:contains("${values[1].label}")`);
            });
    
            it('should have hidden other values after selecting first one', () => {
                currentValue = values[0];
                component.click('.explore-span-filter', new Event('click'));
                component.click(`a.explore-filter-link:contains("${values[1].label}")`, new Event('click'));
                component.should.not.have(`a.explore-filter-link`);
                expect(currentValue.value).toBe(values[1].value);
            });
        });

        describe('2 columns', () => {
            const values = [
                {
                    label: 'First Name',
                    value: 'first_value'
                },
                {
                    label: 'Second Name',
                    value: 'second_value'
                },
            ];
    
            let currentValue = values[0];
    
            /** @type {ExploreFilterAttrs} */
            const attrs = {
                values,
                isSelected: (item) => item.value === currentValue.value,
                itemToString: (item) => item.label,
                mobileLabel: 'MOBILE_LABEL',
                onSelect: (item) => currentValue = item,
                selectedItem: () => currentValue,
                splitNumberColumns: 2,
            };
    
            let component = null;
            let rawComponent = null;
    
            beforeEach(() => {
                rawComponent = m(ExploreFilterSelect, attrs);
                component = mq(rawComponent);
            });

            it('should display 2 columns', () => {
                component.click('.explore-span-filter', new Event('click'));
                component.should.have(2, '.explore-filter-select-col');
            });

            it('should display the selection of values', () => {
                const event = new Event('click');
                component.click('.explore-span-filter', event);
                component.should.have(`a.explore-filter-link:contains("${values[0].label}")`);
            });
    
            it('should select other values', () => {
                component.click('.explore-span-filter', new Event('click'));
                component.click(`a.explore-filter-link:contains("${values[1].label}")`, new Event('click'));
                component.should.have(`.inline-block:contains("${values[1].label}")`);
            });
    
            it('should have hidden other values after selecting first one', () => {
                currentValue = values[0];
                component.click('.explore-span-filter', new Event('click'));
                component.click(`a.explore-filter-link:contains("${values[1].label}")`, new Event('click'));
                component.should.not.have(`a.explore-filter-link`);
                expect(currentValue.value).toBe(values[1].value);
            });
        })
        
    });

});