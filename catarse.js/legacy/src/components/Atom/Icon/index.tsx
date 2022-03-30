import m from 'mithril'
import { withHooks } from 'mithril-hooks';
import iconPath from './icons';
import '@/styles/GlobalStyles.scss';

interface IconProps {
    size?: number;
    color?: string;
    icon: string;
};

export const Icon = withHooks<IconProps>(_Icon);

function _Icon({
    icon,
    color = "$color-icon-default",
    size = 24,
    ...rest }: IconProps) {

    return (
        <svg
            width={`${size}px`}
            height={`${size}px`}
            viewBox={`0 0 24 24`}
            xmlns="http://www.w3.org/2000/svg"
            {...rest}
        >
            <path fill={color} d={iconPath[icon]} />
        </svg>
    );
};

