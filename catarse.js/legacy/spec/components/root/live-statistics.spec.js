import mq from 'mithril-query';
import liveStatistics from '../../../src/root/live-statistics';
import h from '../../../src/h';

describe('pages.LiveStatistics', () => {
  let $output, statistic;

  describe('view', () => {
    beforeAll(() => {
      statistic = StatisticMockery()[0];
      let component = m(liveStatistics);
      $output = mq(component);
    });

    it('should render statistics', () => {
      // expect($output.contains(h.formatNumber(statistic.total_contributed, 2, 3))).toEqual(true);
      // expect($output.contains(statistic.total_contributors)).toEqual(true);
      pending();
    });
  });
});
