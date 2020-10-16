import mq from 'mithril-query';
import m from 'mithril';
import prop from 'mithril/stream';
import _ from 'underscore';
import h from '../../src/h';
import userSettingsSavedCreditCards from '../../src/c/user-settings-saved-credit-cards';

describe('UserSettingsSavedCreditCards', () => {
    let $output;
    let deleteFormSubmit;
    const 
        user = {
            id: 'b1928319b2-91283b0123-123'
        },
        creditCards = prop([
            {
                id: 1,
                last_digits: '1111',
                card_brand: 'visa'
            }
        ]),
        toDeleteCard = prop(-1),
        deleteCard = id => () => {
            toDeleteCard(id);
            // We must redraw here to update the action output of the hidden form on the DOM.
            m.redraw(true);
            deleteFormSubmit();
            return false;
        },
        setCardDeletionForm = (el, isInit) => {
            if (!isInit) {
                deleteFormSubmit = () => el.submit();
            }
        };

    describe('view', () => {

        beforeAll(() => {
            $output = mq(m(userSettingsSavedCreditCards, { user, creditCards, setCardDeletionForm, deleteCard, toDeleteCard }));
        });

        it('should contains card entry row', () => {
            expect($output.contains(creditCards()[0].last_digits)).toBeTrue();
        });

        it('should contains card brand entry row', () => {
            expect($output.contains(creditCards()[0].card_brand.toUpperCase())).toBeTrue();
        });
    });
});
