import mq from 'mithril-query';
import thankYou from '../../../src/root/thank-you'
import prop from 'mithril/stream';

describe('ThankYou', () => {
    let $slip, $cc, $pix;
    let test = (payment) => {
        return {
            contribution: ContributionAttrMockery(null, payment)
        };
    };

    beforeAll(() => {
        const slipOptions = test('slip');
        $slip = mq(m(thankYou, slipOptions));

        const ccOptions = test('creditcard');
        $cc = mq(m(thankYou, ccOptions));

        const pixOptions = test('pix');
        $pix = mq(m(thankYou, pixOptions));
    });

    it('should render a thank you page', () => {
        $slip.should.have('#thank-you');
        $cc.should.have('#thank-you');
        $pix.should.have('#thank-you');
    });

    it('should render 3 recommended projects if not slip payment', () => {
        // expect($cc.find('.card-project').length).toEqual(3);
        expect($slip.find('.card-project').length).toEqual(0);
        pending();
    });

    it('should render the slip iframe if slip payment', () => {
        expect($slip.has('iframe.slip')).toBeTrue();
        expect($cc.has('iframe.slip')).toBeFalse();
    });
});
