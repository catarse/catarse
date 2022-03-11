import m from 'mithril'
import { useState, withHooks } from 'mithril-hooks';
import { If } from '@/shared/components/if';
import { Button } from '@/components/Atom/Button';
import { Icon } from '@/components/Atom/Icon';
import './styles.scss';

export type BannerProps = {
    type?: 'default' | 'success' | 'critical' | 'informational' | 'warning';
    content: string;
    heading?: string;
    isDismissable?: boolean;
    buttonPrimaryLabel?: string;
    buttonSecondaryLabel?: string;
    buttonPrimaryOnClick?: () => any;
    buttonSecondaryOnClick?: () => any;
}

export const Banner = withHooks<BannerProps>(_Banner);

function _Banner({
    type = 'default',
    content,
    heading = '',
    isDismissable = false,
    buttonPrimaryLabel,
    buttonSecondaryLabel,
    buttonPrimaryOnClick,
    buttonSecondaryOnClick,
}: BannerProps) {

    const [isVisible, setIsVisible] = useState(true);

    const hasPrimaryButton = !!(buttonPrimaryLabel && buttonPrimaryOnClick);
    const hasSecondaryButton = !!(buttonSecondaryLabel && buttonSecondaryOnClick);
    const hasActions = hasPrimaryButton || hasSecondaryButton;

    const styleButton = {
        default: 'secondary',
        success: 'primary',
        critical: 'danger',
        informational: 'secondary',
        warning: 'secondary',
    }

    if (isVisible) {
        return (
            <div className={`banner banner-${type}`}>
                <div className='banner-content' >
                    <div className="alert-icon">
                        <Icon icon='circleInformation' size={24}/>
                    </div>

                    <div className="banner-inner-content">
                        <If condition={!!heading}>
                            <p className="text-style-heading">{heading}</p>
                        </If>

                        <p className="text-style-body">{content}</p>

                        <If condition={hasActions}>
                            <div className="banner-footer">
                                <If condition={hasPrimaryButton}>
                                    <Button
                                        size='sm'
                                        theme={styleButton[type]}
                                        variant='outline'
                                        onclick={buttonPrimaryOnClick}
                                    >
                                        {buttonPrimaryLabel}
                                    </Button>
                                </If>

                                <If condition={hasSecondaryButton}>
                                    <Button
                                        size='sm'
                                        theme={styleButton[type]}
                                        variant='text'
                                        onclick={buttonSecondaryOnClick}
                                    >
                                        {buttonSecondaryLabel}
                                    </Button>
                                </If>
                            </div>
                        </If>
                    </div>

                    <If condition={isDismissable}>
                        <div className='banner-dismiss' onclick={() => setIsVisible(false)}>
                            <Icon icon='cancel' size={24}/>
                        </div>
                    </If>
                </div>
            </div>
        );
    }
};

