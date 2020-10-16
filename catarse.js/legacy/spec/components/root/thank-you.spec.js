import mq from 'mithril-query';
import thankYou from '../../../src/root/thank-you'
import prop from 'mithril/stream';

describe('ThankYou', () => {
    let $slip, $cc;
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
    });

    it('should render a thank you page', () => {
        $slip.should.have('#thank-you');
        $cc.should.have('#thank-you');
    });

    it('should render a specific message according to payment type', () => {
        $cc.should.have('#creditcard-thank-you');
        $cc.should.not.have('#slip-thank-you');
        $slip.should.have('#slip-thank-you');
        $slip.should.not.have('#creditcard-thank-you');
    });

    it('should render share buttons if credit card', () => {
        // 3 desktop share buttons
        expect($cc.find('.btn-large').length).toEqual(4)
        expect($slip.find('.btn-large').length).toEqual(0);
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
