import mq from 'mithril-query';
import userFilterVM from '../../../src/vms/user-filter-vm';

describe('admin.userFilterVM', function() {
  var vm = userFilterVM;

  describe("deactivated_at.toFilter", function() {
    it("should parse string inputs to json objects to send filter", function() {
      vm.deactivated_at('null');
      expect(vm.deactivated_at.toFilter()).toEqual(null);
    });
  });

  describe("full_text_index.toFilter", function() {
    it("should remove all diacritics to send filter", function() {
      vm.full_text_index('rémoção dos acêntüs');
      expect(vm.full_text_index.toFilter()).toEqual('remocao dos acentus');
    });
  });
});
