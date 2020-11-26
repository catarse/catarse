import mq from 'mithril-query';
import m from 'mithril';
import UserSettingsHelp from '../../src/c/user-settings-help';

describe('UserSettingsHelp', () => {
    let $output;

    describe('view', () => {

        beforeAll(() => {
            $output = mq(m(UserSettingsHelp, {}));
        });

        it('should contains the link to presentation of help', () => {
            expect($output.find('.w-video.w-embed > iframe.embedly-embed').length == 1).toBeTrue();
        });

        it('should contains the link to article of help', () => {
            expect($output.find('a.fontsize-smaller.alt-link').length == 2).toBeTrue();
        });
    });
});
