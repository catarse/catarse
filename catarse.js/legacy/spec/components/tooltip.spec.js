import mq from 'mithril-query';
import m from 'mithril';
import tooltip from '../../src/c/tooltip';

describe('Tooltip', () => {
    let $output,
        element = 'a#tooltip-trigger[href="#"]',
        text = 'tooltipText',
        tooltipEl = (el) => {
            return m(tooltip, {
                el: el,
                text: text,
                width: 320
            });
        };

    describe('view', () => {
        beforeEach(() => {
            $output = mq(tooltipEl(element));
        });

        it('should not render the tooltip at first', () => {
            expect($output.find('.tooltip').length).toEqual(0);
        });
        it('should render the tooltip on element mouseenter', () => {
            $output.click('#tooltip-trigger');
            expect($output.find('.tooltip').length).toEqual(1);
            expect($output.contains(text)).toBeTrue();
        });
        it('should hide the tooltip again on element mouseleave', () => {
            $output.click('#tooltip-trigger');
            $output.click('#tooltip-trigger');
            expect($output.find('.tooltip').length).toEqual(0);
        });
    });
});
