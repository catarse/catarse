import m from 'mithril';
import h from '../h';

const postForRewardCheckbox = {
    view: function({attrs}) {
        const r = attrs.reward,
            reward_checkbox = attrs.reward_checkbox,
            chk_label = `R$${ h.formatNumber(parseInt(r.data.minimum_value))} - ${r.data.title ? r.data.title : `${r.data.description.substring(0, 30)}...`}`,
            sublabel = `${attrs.contributions_count} ${attrs.sublabel}`;

        return m('.u-marginbottom-10.w-checkbox', [
            m(`input.w-checkbox-input[type=checkbox]`, {
                onchange: () => reward_checkbox.toggle(),
                checked: reward_checkbox()
            }),
            m('label.fontsize-smaller.fontweight-semibold.lineheight-tighter.w-form-label', {
                onclick: () => reward_checkbox.toggle()
            }, chk_label),
            m('.fontsize-smallest.fontcolor-secondary.lineheight-tightest', sublabel)
        ]);
    }
};

export default postForRewardCheckbox;