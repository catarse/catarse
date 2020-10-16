import mq from 'mithril-query';
import m from 'mithril';
import dashboardInfo from '../../src/c/dashboard-info';

describe('Dashboard Info', () => {
    let $output,
        content = {
            icon: 'url://to.icon',
            title: 'title',
            href: '#where-to',
            cta: 'next step'
        };

    describe('view', () => {
        beforeEach(() => {
            $output = mq(m(dashboardInfo, {content: content}));
        });

        it('should render an given icon', () => {
            expect($output.has(`img[src="${content.icon}"]`)).toBeTrue();
        });
        it('should render an given title', () => {
            expect($output.contains(content.title)).toBeTrue();
        });
        it('should render an given href', () => {
            expect($output.has(`a[href="${content.href}"]`)).toBeTrue();
        });
        it('should render an given cta', () => {
            expect($output.contains(content.cta)).toBeTrue();
        });
    });
});
