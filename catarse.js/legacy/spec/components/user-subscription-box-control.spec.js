import mq from 'mithril-query';
import m from 'mithril';
import moment from 'moment';
import h from '../../src/h';
import UserSubscriptionBoxControl from '../../src/c/user-subscription-box-control';

describe('UserSubscriptionBoxControl', () => {

    describe('view', function() {
        let redoPaymentButton,
            generateSecondSlipButton,
            printSecondSlipButton,
            waitingCreditCardPaymentConfirm,
            inactiveSubscriptionWaitingBoletoPayment,
            inactiveSubscriptionMissingPayment,
            userCanceledItsOwnSubscription,
            userSubscriptionIsInCancelingState,
            activeSubscriptionLastPaymentRefused,
            activeSubscriptionWithPaidPayment,
            activeSubscriptionExpiredSlip,
            activeSubscriptionNotExpiredSlip;

        beforeAll(function() {

            const data = SubscriptionBoxData();
            
            redoPaymentButton = mq(m(UserSubscriptionBoxControl, {subscription: data[0]}));
            generateSecondSlipButton = mq(m(UserSubscriptionBoxControl, {subscription: data[1], isGeneratingSecondSlip: () => false }));
            printSecondSlipButton = mq(m(UserSubscriptionBoxControl, {subscription: data[2]}));
            waitingCreditCardPaymentConfirm = mq(m(UserSubscriptionBoxControl, { subscription: data[3] }));
            inactiveSubscriptionWaitingBoletoPayment = mq(m(UserSubscriptionBoxControl, { subscription: data[4] }));
            inactiveSubscriptionMissingPayment = mq(m(UserSubscriptionBoxControl, { subscription: data[5] }));
            userCanceledItsOwnSubscription = mq(m(UserSubscriptionBoxControl, { subscription: data[6] }));
            userSubscriptionIsInCancelingState = mq(m(UserSubscriptionBoxControl, { subscription: data[7] }));
            activeSubscriptionLastPaymentRefused = mq(m(UserSubscriptionBoxControl, { subscription: data[8] }));
            activeSubscriptionWithPaidPayment = mq(m(UserSubscriptionBoxControl, { subscription: data[9], showLastSubscriptionVersionEditionNextCharge: () => '' }));
            activeSubscriptionExpiredSlip = mq(m(UserSubscriptionBoxControl, { subscription: data[10], showLastSubscriptionVersionEditionNextCharge: () => '', isGeneratingSecondSlip: () => false}));
            activeSubscriptionNotExpiredSlip = mq(m(UserSubscriptionBoxControl, { subscription: data[11], showLastSubscriptionVersionEditionNextCharge: () => '', isGeneratingSecondSlip: () => false}));
        });

        it('should show redo payment credit card and cancel buttons', function() {
            expect(redoPaymentButton.contains('Refazer pagamento')).toBeTruthy();
            expect(redoPaymentButton.contains('Cancelar assinatura')).toBeTruthy();
        });

        it('should show generate second slip and cancel buttons', function() {
            expect(generateSecondSlipButton.contains('Gerar segunda via')).toBeTruthy();
            expect(generateSecondSlipButton.contains('Cancelar assinatura')).toBeTruthy();
        });

        it('should show print slip and cancel buttons', function() {
            expect(printSecondSlipButton.contains('Imprimir boleto')).toBeTruthy();
            expect(printSecondSlipButton.contains('Cancelar assinatura')).toBeTruthy();
        });

        it('should show wait payment approve confirmation', function() {
            expect(waitingCreditCardPaymentConfirm.contains('Aguardando confirmação do pagamento')).toBeTruthy();
        });

        it('should show print slip for inactive subscription', function() {
            expect(inactiveSubscriptionWaitingBoletoPayment.contains('Imprimir boleto')).toBeTruthy();
        });

        it('should show re-subscription button', function() {
            expect(inactiveSubscriptionMissingPayment.contains('Assinar novamente')).toBeTruthy();
            expect(userCanceledItsOwnSubscription.contains('Assinar novamente')).toBeTruthy();
        });

        it('should show message of canceling by user cancel request', function() {
            expect(userSubscriptionIsInCancelingState.contains(` Sua assinatura será cancelada no dia ${
                h.momentify(moment().add(1, 'days'), 'DD/MM/YYYY')
            }. Até lá, ela ainda será considerada ativa.`)).toBeTruthy();
        });

        it('should show redo payment and cancel subscription buttons', function() {
            expect(activeSubscriptionLastPaymentRefused.contains('Refazer pagamento')).toBeTruthy();
            expect(activeSubscriptionLastPaymentRefused.contains('Cancelar assinatura')).toBeTruthy();
        });

        it('should show edit and cancel subscription buttons paid payment', function() {
            expect(activeSubscriptionWithPaidPayment.contains('Editar assinatura')).toBeTruthy();
            expect(activeSubscriptionWithPaidPayment.contains('Cancelar assinatura')).toBeTruthy();
        });
        
        it('should show generate second slip and cancel buttons for active subscription', function() {
            expect(activeSubscriptionExpiredSlip.contains('Gerar segunda via')).toBeTruthy();
            expect(activeSubscriptionExpiredSlip.contains('Cancelar assinatura')).toBeTruthy();
        });

        it('should show print slip and cancel buttons for active subscription', function() {
            expect(activeSubscriptionNotExpiredSlip.contains('Imprimir boleto')).toBeTruthy();
            expect(activeSubscriptionNotExpiredSlip.contains('Cancelar assinatura')).toBeTruthy();
        });        
    });
});