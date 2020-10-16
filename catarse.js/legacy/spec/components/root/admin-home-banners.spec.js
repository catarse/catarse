import mq from 'mithril-query';
import prop from 'mithril/stream';
import AdminHomeBanners from '../../../src/root/admin-home-banners';

describe('AdminHomeBanners', () => {
    let $output, title = 'TitleSample',
        defaultDocumentWidth = 1600,
        vm = {
            banners: prop([
                {
                    title: 'title 1',
                    subtitle: 'subtitle 1',
                    link: 'The link',
                    cta: 'The CTA',
                    image: 'This is the image link!!!',
                },
                {
                    title: 'title 2',
                    subtitle: 'subtitle 2',
                    link: 'The link',
                    cta: 'The CTA',
                    image: 'This is the image link!!!',
                },
            ]),
            updateBanners(newBanners) {
                // MOCK FUNCTION
            },
        };

    describe('view', () => {
        beforeEach(() => {
            $output = mq(AdminHomeBanners, { vm });
        });

        it('should render all the slides entries', () => {
            expect($output.find('.slide-entry').length).toEqual(vm.banners().length);
        });
        
        it('should render all slides data entries', () => {
            expect($output.find('input.text-field.w-input[type="text"]').length).toEqual(vm.banners().length * Object.keys(vm.banners()[0]).length);
        });
    });
});