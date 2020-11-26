import mq from 'mithril-query';
import h from '../../src/h';

describe('helper methods', () => {
    describe('h.formatNumber', () => {
        let number = null,
            formatNumber = h.formatNumber;

        it('should format number', () => {
            number = 120.2;
            expect(formatNumber(number)).toEqual('120');
            expect(formatNumber(number, 2, 3)).toEqual('120,20');
            expect(formatNumber(number, 2, 2)).toEqual('1.20,20');
        });
    });

    describe('h.rewardSouldOut', () => {
        let reward = null,
            rewardSouldOut = h.rewardSouldOut;

        it('return true when reward already sould out', () => {
            reward = {
                maximum_contributions: 5,
                paid_count: 3,
                waiting_payment_count: 2,
            };

            expect(rewardSouldOut(reward)).toEqual(true);
        });

        it('return false when reward is not sould out', () => {
            reward = {
                maximum_contributions: 5,
                paid_count: 3,
                waiting_payment_count: 1,
                run_out: false,
            };

            expect(rewardSouldOut(reward)).toEqual(false);
        });

        it('return false when reward is not defined maximum_contributions', () => {
            reward = {
                maximum_contributions: null,
                paid_count: 3,
                waiting_payment_count: 1,
                run_out: false,
            };

            expect(rewardSouldOut(reward)).toEqual(false);
        });
    });

    describe('h.rewardRemaning', () => {
        let reward,
            rewardRemaning = h.rewardRemaning;

        it('should return the total remaning rewards', () => {
            reward = {
                maximum_contributions: 10,
                paid_count: 3,
                waiting_payment_count: 2,
            };

            expect(rewardRemaning(reward)).toEqual(5);
        });
    });

    describe('h.parseUrl', () => {
        let url,
            parseUrl = h.parseUrl;

        it('should create an a element', () => {
            url = 'http://google.com';
            expect(parseUrl(url).hostname).toEqual('google.com');
        });
    });

    describe('h.pluralize', () => {
        let count,
            pluralize = h.pluralize;

        it('should use plural when count greater 1', () => {
            count = 3;
            expect(pluralize(count, ' dia', ' dias')).toEqual('3 dias');
        });

        it('should use singular when count less or equal 1', () => {
            count = 1;
            expect(pluralize(count, ' dia', ' dias')).toEqual('1 dia');
        });
    });

    /*describe('h.analytics', () => {
      let ga;
      beforeEach(() => {
        ga = window.ga = jasmine.createSpy('ga');
        ga.getAll=function(){};
      });
      it('should not call ga if does not pass eventObj', () => {
        expect(h.analytics.event()).toEqual(Function.prototype);
        expect(ga).not.toHaveBeenCalled();
      });
      it('should not call ga if does not pass eventObj 2', () => {
        let f=function() {};
        let f2=h.analytics.event(null, f);
        expect(f2).toBe(f);
        f2();
        expect(ga).not.toHaveBeenCalled();
      });
      it('should call ga if pass eventObj', () => {
        let obj={cat:'link',act:'click',lbl:'http://teste.com'};
        let f=h.analytics.event(obj);
        expect(f).toEqual(jasmine.any(Function));
        f();
        expect(ga).toHaveBeenCalledWith('send','event','link','click','http://teste.com',undefined,jasmine.any(Object));
      });
    });*/
});
