import mq from 'mithril-query';
import contributionFilterVM from '../../../src/vms/contribution-filter-vm';
import h from '../../../src/h';

describe('admin.contributionFilterVM', function() {
  var vm = contributionFilterVM,
      momentFromString = h.momentFromString;

  describe("created_at.lte.toFilter", function() {
    it("should use end of the day timestamp to send filter", function() {
      vm.created_at.lte('21/12/1999');
      expect(vm.created_at.lte.toFilter()).toEqual(momentFromString(vm.created_at.lte()).endOf('day').format());
    });
  });

  describe("full_text_index.toFilter", function() {
    it("should remove all diacritics to send filter", function() {
      vm.full_text_index('rémoção dos acêntüs');
      expect(vm.full_text_index.toFilter()).toEqual('remocao dos acentus');
    });
  });
});
