import m from 'mithril'
import { withHooks } from 'mithril-hooks';
import { If } from '@/shared/components/if';
import { Icon } from '@/components/Atom/Icon';
import './styles.scss';

interface ButtonProps extends HTMLButtonElement {
    theme?: 'primary' | 'secondary' | 'danger' | string;
    variant?: 'contained' | 'outline' | 'text';
    leftIcon?: string;
    rightIcon?: string;
    size?: 'sm' | 'md' | 'lg';
}

export const Button = withHooks<ButtonProps>(_Button);

function _Button({
    theme = 'primary',
    variant = 'contained',
    size = 'md',
    leftIcon = null,
    rightIcon = null,
    children = null,
    ...rest
}: ButtonProps) {

    return (
        <button
            className={`btn-main btn-${variant} btn-${theme} btn-size-${size} text-style-button `}
            {...rest}
        >
            <div>
                <If condition={!!leftIcon}>
                    <Icon icon={leftIcon} size={16} />
                </If>

                {children}

                <If condition={!!rightIcon}>
                    <Icon icon={rightIcon} size={16} />
                </If>
            </div>
        </button>
    );
};

