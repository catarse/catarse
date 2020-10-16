import m from 'mithril';
import mq from 'mithril-query';
import mr from 'mithril-node-render';
import { ExploreSearchFilterSelect } from '../../src/c/explore/explore-search-filter-select';

describe('ExploreFilterSelect', () => {

    describe('view', () => {

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

        let currentValue = null;

        /** @type {ExploreFilterAttrs} */
        const attrs = {
            onSearch: (searchText) => {},
            onSelect: (item) => currentValue = item,
            selectedItem: (item) => currentValue,
            foundItems: () => values,
            noneSelected: 'NONE_SELECTED',
            mobileLabel: 'MOBILE_LABEL',
            itemToString: (item) => item.label,
            isLoading: () => false,
        };

        let component = null;
        let rawComponent = null;

        beforeEach(() => {
            rawComponent = m(ExploreSearchFilterSelect, attrs);
            component = mq(rawComponent);
        });

        it('should init diplaying none selected label', () => {
            component.should.have(`.explore-span-filter-name > .inline-block:contains("${attrs.noneSelected}")`);
        });
        
        it('should display the selection of values', () => {
            const event = new Event('click');
            component.click('.explore-span-filter', event);
            component.should.have(`a.fontsize-smallest.link-hidden-light:contains("${values[0].label}")`);
            component.should.have(`a.fontsize-smallest.link-hidden-light:contains("${values[1].label}")`);
        });

        it('should select other values', () => {
            component.click('.explore-span-filter', new Event('click'));
            component.click(`a.fontsize-smallest.link-hidden-light:contains("${values[0].label}")`,  new Event('click'));
            component.should.have(`.explore-span-filter-name > .inline-block:contains("${values[0].label}")`);
        });

        it('should clear selected value', () => {
            currentValue = null;
            component.click('.explore-span-filter', new Event('click'));
            component.click(`a.fontsize-smallest.link-hidden-light:contains("${values[0].label}")`,  new Event('click'));
            component.should.not.have(`a.fontsize-smallest.link-hidden-light`);
            expect(currentValue.value).toBe(values[0].value);
            component.click('.inline-block.fa.fa-times', new Event('click'));
            component.should.have(`.explore-span-filter-name > .inline-block:contains("${attrs.noneSelected}")`);
        });

        it('should display none selected when search don\'t find any result and select it', () => {
            currentValue = null;
            component.click('.explore-span-filter', new Event('click'));
            component.click(`a.fontsize-smallest.link-hidden-light:contains("${values[0].label}")`,  new Event('click'));
            component.should.not.have(`a.fontsize-smallest.link-hidden-light`);
            expect(currentValue.value).toBe(values[0].value);
            attrs.foundItems = () => [];
            component.click('.explore-span-filter', new Event('click'));
            component.should.have(`a.fontsize-smallest.link-hidden-light:contains("${attrs.noneSelected}")`);
            component.click(`a.fontsize-smallest.link-hidden-light:contains("${attrs.noneSelected}")`, new Event('click'));
            component.should.have(`.explore-span-filter-name > .inline-block:contains("${attrs.noneSelected}")`);
            component.should.not.have(`a.fontsize-smallest.link-hidden-light`);
        });

        it('should display loader when load time of search delays', () => {
            currentValue = null;
            attrs.foundItems = () => [];
            attrs.isLoading = () => true;
            component.click('.explore-span-filter', new Event('click'));
            component.should.not.have(`a.fontsize-smallest.link-hidden-light`);
            component.should.have('.u-text-center.u-margintop-30.u-marginbottom-30 > img[alt="Loader"]');
        });

    });

});
