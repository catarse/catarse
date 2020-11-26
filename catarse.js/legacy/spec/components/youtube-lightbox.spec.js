import mq from 'mithril-query';
import youtubeLightbox from '../../src/c/youtube-lightbox';

describe('YoutubeLightbox', () => {
    let $output,
        visibleStyl = 'display:block',
        invisibleStyl = 'display:none';

    describe('view', () => {
        beforeEach(() => {
            $output = mq(youtubeLightbox, {src: 'FlFTcDSKnLM'});
        });

        it('should not render the lightbox at first', () => {
            expect($output.find('#lightbox')[0].attrs.style).toEqual(invisibleStyl);
        });
        it('should render the lightbox on play button click', () => {
            $output.click('#youtube-play');
            expect($output.find('#lightbox')[0].attrs.style).toEqual(visibleStyl);
        });
        it('should close the lightbox on close button click', () => {
            $output.click('#youtube-play');
            $output.click('#youtube-close');
            expect($output.find('#lightbox')[0].attrs.style).toEqual(invisibleStyl);
        });
    });
});
