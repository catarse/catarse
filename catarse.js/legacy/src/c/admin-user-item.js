import m from 'mithril';
import h from '../h';
import adminUser from './admin-user';

const adminUserItem = {
    view: function({state, attrs}) {
        return m(
            '.w-row', [
                m('.w-col.w-col-4', [
                    m(adminUser, attrs)
                ])
            ]
        );
    }
};

export default adminUserItem;
