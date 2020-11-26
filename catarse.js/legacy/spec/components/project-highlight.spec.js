import mq from 'mithril-query';
import m from 'mithril';
import prop from 'mithril/stream';
import projectHighlight from '../../src/c/project-highlight';

describe('ProjectHighlight', () => {
    let $output, projectDetail;

    it('when project video is not filled should render image', () => {
        projectDetail = prop(_.extend({}, ProjectDetailsMockery()[0], {
            original_image: 'original_image',
            video_embed_url: null
        }));
        let component = m(projectHighlight, {
                project: projectDetail
            });
        $output = mq(component);

        expect($output.find('.project-image').length).toEqual(1);
        expect($output.find('iframe.embedly-embed').length).toEqual(0);
    });

    describe('view', () => {
        beforeAll(() => {
            projectDetail = prop(ProjectDetailsMockery()[0]);
            $output = mq(projectHighlight, {
                project: projectDetail
            });
        });

        it('should render project video, headline, category and address info', () => {
            expect($output.find('iframe.embedly-embed').length).toEqual(1);
            expect($output.find('span.fa.fa-map-marker').length).toEqual(1);
            expect($output.contains(projectDetail().address.city)).toEqual(true);
        });

        it('should render project share box when click on share', () => {
            $output.click('#more-share');
            $output.redraw();
            $output.should.have('.pop-share');
        });
    });
});
