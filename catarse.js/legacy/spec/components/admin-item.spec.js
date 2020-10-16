import mq from 'mithril-query';
import m from 'mithril';
import adminItem from '../../src/c/admin-item';

describe('AdminItem', () => {
    let item, $output, ListItemMock, ListDetailMock;

    beforeAll(() => {
        ListItemMock = {
            view: (ctrl, args) => {
                return m('.list-item-mock');
            }
        };
        ListDetailMock = {
            view: (ctrl, args) => {
                return m('.list-detail-mock');
            }
        };
    });

    describe('view', () => {
        beforeEach(() => {
            $output = mq(adminItem, {
                listItem: ListItemMock,
                listDetail: ListDetailMock,
                item: item
            });
        });

        it('should render list item', () => {
            $output.should.have('.list-item-mock');
        });

        it('should render list detail when toggle details is true', () => {
            $output.click('button');
            $output.should.have('.list-detail-mock');
        });

        it('should not render list detail when toggle details is false', () => {
            $output.should.not.have('.list-detail-mock');
        });
    });

});
