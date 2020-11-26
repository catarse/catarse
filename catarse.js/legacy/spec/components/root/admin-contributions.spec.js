import mq from 'mithril-query';
import adminContributions from '../../../src/root/admin-contributions';

describe('adminContributions', () => {
  let ctrl, $output;

    beforeAll(() => {
      $output = mq(adminContributions);
    });
    it('should instantiate a list view-model', () => {
      expect($output.vnode.state.listVM).toBeDefined();
    });

    it('should instantiate a filter view-model', () => {
      expect($output.vnode.state.filterVM).toBeDefined();
    });

    it('should render AdminFilter nested component', () => {
      expect($output.has('#admin-contributions-filter')).toBeTrue();
    });
    it('should render AdminList nested component', () => {
      expect($output.has('#admin-contributions-list')).toBeTrue();
    });
  });

