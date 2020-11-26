import m from 'mithril';

const anonymousBadge = {

    view: function({attrs}) {
        
        if (attrs.isAnonymous) {
            return m('span.fa.fa-eye-slash.fontcolor-secondary', 
                m('span.fontcolor-secondary[style="font-size:11px;"]', attrs.text)
            );
        }
        else {
            return m('div');
        }
    }
};

export default anonymousBadge;